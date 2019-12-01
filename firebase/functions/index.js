const functions = require('firebase-functions');
const Filter = require('bad-words');
const admin = require('firebase-admin');
admin.initializeApp();

const badwordsFilter = new Filter();
const minLength = 4;
const maxLength = 15;

const userRoleOwner = 1;
const userRoleAdmin = 2;
const userRoleMember = 3;

const userRolesWithInviteRights = [
    userRoleOwner,
    userRoleAdmin
];

const userRolesWithManageRights = [
    userRoleOwner
];

exports.onUserAccountCreate = functions
    .region('europe-west2')
    .auth
    .user()
    .onCreate(async (user) => {
        let userAccount = null;
        try {
            userAccount = await admin.auth().getUser(user.uid);
        } catch (e) {
            // Assume account deleted
            userAccount = null;
        }

        if (userAccount === null || userAccount === undefined) {
            return null;
        }

        const db = admin.firestore();
        await db.runTransaction(async (transaction) => {
                try {
                    const documentRef = db.collection('users').doc(`${user.uid}`);
                    const snapshot = await transaction.get(documentRef);
                    if (snapshot.data() !== undefined) {
                        return Promise.resolve('Data already created')
                    }

                    return transaction.set(documentRef, {
                        displayName: 'User'
                    });
                } catch (e) {
                    return Promise.reject(e);
                }
            })
            .then((_) => {
                console.log(`Finished User data verification for ${user.uid}`);
                return null;
            })
            .catch((error) => {
                console.log(`Failed to verify User data when creating user ${user.uid} : ${error}`);
                return null;
            });

        return null;
    });

exports.onUserAccountDelete = functions
    .region('europe-west2')
    .auth
    .user()
    .onDelete(async (user) => {
        return deleteUserData(user.uid);
    });

exports.onUserDataWrite = functions
    .region('europe-west2')
    .firestore
    .document('/users/{userId}')
    .onWrite(async (change) => {
        const newUserData = change.after.data();

        if (newUserData === undefined || nameValid(newUserData)) {
            return null;
        }

        const oldUserdata = change.before.exists ? change.before.data() : null;
        const name = oldUserdata !== null && oldUserdata.displayName !== null ? oldUserdata.displayName : 'User';

        console.log(`Sanitizing name ${newUserData.displayName} to ${name}`);
        console.log(newUserData);
        const sanitizedData = {
            ...newUserData,
            displayName: name
        };
        console.log(sanitizedData);
        return change.after.ref.update(sanitizedData);
    });

exports.onUserDataUpdate = functions
    .region('europe-west2')
    .firestore
    .document('/users/{userId}')
    .onUpdate(async (change) => {
        const userData = change.after.data();
        if (userData === null || userData === undefined) {
            console.log('OnUserDataUpdate triggered for undefined');
            return null;
        }

        if (userData.groups === null || userData.groups === undefined) {
            return null;
        }

        try {
            const userId = change.after.id
            const groupRequests = [];
            userData.groups.forEach(group => {
                console.log(`User ${userId} belongs to Group ${group.name} (Group ID ${group.id})`);
                groupRequests.push(admin.firestore().doc(`groups/${group.id}`).get());
            });

            const snapshots = await Promise.all(groupRequests);
            const updateRequests = [];
            snapshots.forEach(snapshot => {
                const groupData = snapshot.data();
                const updatedMembers = [];

                if (groupData.members === null || groupData.members === undefined) {
                    console.warn(`Group ${snapshot.id} has null members`);
                } else {
                    groupData.members.forEach(member => {
                        if (member.userId === userId) {
                            console.log(`Updating user ${userId} data in group ${snapshot.id}`);
                            member.userData = userData;
                        }

                        updatedMembers.push(member);
                    })
                }

                groupData.members = updatedMembers;
                updateRequests.push(snapshot.ref.update(groupData));
            });

            return Promise.all(updateRequests);
        } catch (e) {
            console.error(`Failed to update user's data in groups: ${e}`);
            return null;
        }
    });

exports.onGroupInvitationUpdate = functions
    .region('europe-west2')
    .firestore
    .document('/groupInvitations/{userId}')
    .onUpdate(async (change) => {
        const data = change.after.data();
        const db = admin.firestore();

        if (data === undefined) {
            console.warn('onUpdate triggered for undefined');
            return null;
        }

        const userId = change.after.id;
        const user = await db.doc(`users/${userId}`).get();
        const userData = user.data();

        const invitations = Object.entries(data);
        console.log(invitations);

        if (userData.groups === null || userData.groups === undefined) {
            userData.groups = [];
        }

        const readRequests = []
        const openInvitations = {};
        for (const [groupId, invitation] of invitations) {
            switch (invitation.status) {
                case 1:
                    // Open
                    openInvitations[`${groupId}`] = invitation;
                    break;
                case 2:
                    // Accept
                    readRequests.push(db.doc(`groups/${groupId}`).get());
                    userData.groups.push({
                        id: groupId,
                        name: invitation.groupName,
                        role: userRoleMember
                    });
                    break;
                case 3:
                    // Reject
                    break;
                default:
                    // Panic
                    console.warn(`User ${userId}'s invitation to ${invitation.groupName} (ID ${groupId}) has unknown status ${invitation.status} and will be removed`);
                    break;
            }
        }

        const snapshots = await Promise.all(readRequests);
        const updateRequests = [];
        snapshots.forEach((snapshot) => {
            const group = snapshot.data();
            group.members.push({
                role: userRoleMember,
                userId: userId,
                userData: userData
            });
            updateRequests.push(snapshot.ref.update(group));
        });

        updateRequests.push(user.ref.update(userData));
        updateRequests.push(change.after.ref.set(openInvitations));

        return Promise.all(updateRequests);
    });

// 0 Ok
// -1 User not verified
// -2 Group name invalid
// -3 Group name already in use
// -200 Invalid request / internal error
exports.createGroup =
    functions
    .region('europe-west2')
    .https
    .onCall(async (data, context) => {
        if (context.auth === null || context.auth === undefined) {
            return {
                status: -200
            };
        }

        let authData;
        try {
            authData = await admin.auth().getUser(context.auth.uid);
        } catch (e) {
            console.error(`User ${context.auth.uid} tried to create a group but no auth data found`);
            return {
                status: -200
            };
        }

        console.log(authData);

        if (!authData.emailVerified) {
            return {
                status: -1
            };
        }

        const groupName = data.groupName;

        if (groupName !== badwordsFilter.clean(groupName)) {
            return {
                status: -2
            };
        }

        const db = admin.firestore();

        const existingGroupSnapshot = await db.collection('groups').where('groupName', '==', `${groupName}`).get();
        if (!existingGroupSnapshot.empty) {
            return {
                status: -3
            };
        }

        const userDataSnapshot = await db.doc(`users/${authData.uid}`).get();
        const userData = userDataSnapshot.data();
        if (userData === undefined) {
            console.error(`User ${authData.uid} doens't have matching user data`);
            return {
                status: -200
            };
        }

        const newGroup = {
            groupName: groupName,
            members: [{
                role: userRoleOwner,
                userId: authData.uid,
                userData: userData
            }]
        };

        const newGroupDoc = await db.collection('groups').add(newGroup);

        if (userData.groups === null || userData.groups === undefined) {
            userData.groups = [];
        }

        userData.groups.push({
            id: newGroupDoc.id,
            name: groupName,
            role: userRoleOwner
        });

        await userDataSnapshot.ref.update(userData);

        return {
            status: 0
        };
    });

// 0 Ok
// -1 No user found
// -2 Only admins allowed to invite
// -3 User already in group
// -4 User already invited
// -200 Invalid request
exports.inviteUser = functions
    .region('europe-west2')
    .https
    .onCall(async (data, context) => {
        if (context.auth === null || context.auth === undefined) {
            return {
                status: -200
            };
        }

        const groupId = data.groupId;
        const email = data.email;

        if (email === null || groupId === null) {
            return {
                status: -200
            };
        }
        let user;
        try {
            user = await admin.auth().getUserByEmail(email);
        } catch (e) {
            // Assume user is not found
            return {
                status: -1
            };
        }

        if (user === null) {
            return {
                status: -1
            };
        }

        const db = admin.firestore();

        const group = await db.doc(`groups/${groupId}`).get();
        if (group === null) {
            return {
                status: -200
            };
        }

        const inviter = group.data().members.find((member) => {
            return member.userId === context.auth.uid;
        });

        if (inviter === undefined) {
            console.warn(`Couldn't find ${context.auth.uid} from group ${groupId} even though he's the inviter`);
            return {
                status: -200
            };
        }

        if (!userRolesWithInviteRights.some((role) => role === inviter.role)) {
            return {
                status: -2
            };
        }

        const existingMember = group.data().members.find((member) => {
            return member.userId === user.uid;
        });

        if (existingMember !== undefined) {
            return {
                status: -3
            };
        }

        const userInvitations = await db.doc(`groupInvitations/${user.uid}`).get();
        console.log('User invitations');
        console.log(userInvitations.data());

        if (userInvitations.data() !== undefined &&
            userInvitations.data().groupId !== null &&
            userInvitations.data().groupId !== undefined) {
            return {
                status: -4
            };
        }

        const invitationData = {};
        invitationData[groupId] = {
            groupName: group.data().groupName,
            status: 1,
        };

        await userInvitations.ref.set(invitationData, {
            merge: true
        });

        return {
            status: 0,
        };
    });

// 0 Ok
// -1 Only owners are allowed to update group data
// -200 Invalid request / internal error
exports.updateGroupData = functions
    .region('europe-west2')
    .https
    .onCall(async (data, context) => {

        if (context.auth === null || context.auth === undefined) {
            return {
                status: -200
            };
        }

        const groupId = data.groupId;
        const db = admin.firestore();

        const group = await db.doc(`groups/${groupId}`).get();
        if (group === null) {
            return {
                status: -200
            };
        }

        const author = group.data().members.find((member) => {
            return member.userId === context.auth.uid;
        });

        if (author === undefined) {
            console.warn(`Couldn't find ${context.auth.uid} from group ${groupId} even though he's the author for group data update`);
            return {
                status: -200
            };
        }

        if (!userRolesWithManageRights.some((role) => role === author.role)) {
            return {
                status: -1
            };
        }

        if (data.groupName === null || data.groupName === undefined) {
            return {
                status: 0
            };
        }

        const getRequests = [];
        group.data().members.forEach((member) => {
            getRequests.push(db.doc(`users/${member.userId}`).get());
        })

        const groupName = data.groupName;
        const updatedData = {
            groupName: groupName
        };

        const snapshots = await Promise.all(getRequests);
        const updateRequests = [
            group.ref.set(updatedData, {
                merge: true
            })
        ];

        snapshots.forEach((snapshot) => {
            const user = snapshot.data();
            const updatedGroups = [];

            if (user.groups !== null && user.groups !== undefined) {
                user.groups.forEach((group) => {
                    if (group.id === groupId) {
                        group.name = groupName
                    }

                    updatedGroups.push(group);
                });

                user.groups = updatedGroups;
                updateRequests.push(snapshot.ref.update(user));
            }
        });

        await Promise.all(updateRequests);
        return {
            status: 0,
        };
    });

// 0 Ok
// -1 Invalid group ID
// -2 Invalid group member ID
// -3 Invalid new role
// -4 Only owners are allowed to change group member roles
// -200 Invalid request / internal error
exports.updateGroupMemberRole = functions
    .region('europe-west2')
    .https
    .onCall(async (data, context) => {
        if (context.auth === null || context.auth === undefined) {
            return {
                status: -200
            };
        }

        const groupId = data.groupId;
        const groupMemberId = data.groupMemberId;
        const newRole = data.role;

        if (groupId === null || groupId === undefined) {
            return {
                status: -1
            };
        }

        if (groupMemberId === null || groupMemberId === undefined) {
            return {
                status: -2
            };
        }

        if (newRole === null || newRole === undefined || newRole === userRoleOwner) {
            return {
                status: -3
            };
        }

        const db = admin.firestore();

        const snapshots = await Promise.all([
            db.doc(`/groups/${groupId}`).get(),
            db.doc(`/users/${groupMemberId}`).get()
        ]);

        const groupData = snapshots[0].data();
        const userData = snapshots[1].data();
        if (!groupData === undefined) {
            return {
                status: -1
            };
        }

        if (userData === undefined) {
            return {
                status: -2
            };
        }

        if (!groupData.members.some((member) => {
                return member.userId === context.auth.uid && userRolesWithManageRights.some((role) => {
                    return role === member.role
                })
            })) {
            return {
                status: -4
            };
        }

        const groupMemberIdx = groupData.members.findIndex((member) => member.userId === groupMemberId);

        if (groupMemberIdx === -1) {
            return {
                status: -2
            };
        }

        const userDataGroupIdx = userData.groups.findIndex((group) => group.id === groupId);
        if (userDataGroupIdx === -1) {
            return {
                status: -200
            };
        }

        groupData.members[groupMemberIdx].role = newRole;
        userData.groups[userDataGroupIdx].role = newRole;

        await Promise.all([
            snapshots[0].ref.update(groupData),
            snapshots[1].ref.update(userData)
        ]);

        return {
            status: 0
        };
    })

// 0 Ok
// -1 Active owner of group(s)
// -200 Invalid request / internal error
exports.deleteUser = functions
    .region('europe-west2')
    .https
    .onCall(async (data, context) => {

        if (context.auth === null || context.auth === undefined) {
            return {
                status: -200
            };
        }

        const db = admin.firestore();

        const snapshot = await db.doc(`users/${context.auth.uid}`).get();
        if (snapshot === null || snapshot === undefined) {
            return {
                status: -200
            };
        }

        const user = snapshot.data();

        if (user === undefined) {
            return {
                status: -200
            };
        }

        if (user.groups !== null && user.groups !== undefined && user.groups.some((group) => group.role === userRoleOwner)) {
            return {
                status: -1
            };
        }

        await Promise.all([
            admin.auth().deleteUser(context.auth.uid),
            deleteUserData(context.auth.uid)
        ]);

        return {
            status: 0
        }
    });

function nameValid(userData) {
    return userData.displayName !== null &&
        userData.displayName.length >= minLength &&
        userData.displayName.length <= maxLength &&
        userData.displayName === badwordsFilter.clean(userData.displayName);
}

async function deleteUserData(uid) {
    const db = admin.firestore();
    const userSnapshot = await db.doc(`users/${uid}`).get();

    const userData = userSnapshot.data();
    if (userData === undefined) {
        return Promise.resolve('Already deleted');
    }

    if (userData.groups === null || userData.groups === undefined) {
        return userSnapshot.ref.delete();
    }

    const groupGetRequests = [];
    userData.groups.forEach((group) => {
        groupGetRequests.push(db.doc(`groups/${group.id}`).get());
    });

    const groupSnapshots = await Promise.all(groupGetRequests);

    const writeRequests = [
        db.doc(`groupInvitations/${uid}`).delete()
    ];

    groupSnapshots.forEach((snapshot) => {
        const group = snapshot.data();
        const updatedMembers = [];
        group.members.forEach((member) => {
            if (member.userId !== uid) {
                updatedMembers.push(member);
            }

            group.members = updatedMembers;
            writeRequests.push(snapshot.ref.update(group));
        });
    });

    writeRequests.push(userSnapshot.ref.delete());

    return Promise.all(writeRequests);
}