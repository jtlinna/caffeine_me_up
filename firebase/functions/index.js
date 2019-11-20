const functions = require('firebase-functions');
const Filter = require('bad-words');
const admin = require('firebase-admin');
admin.initializeApp();

const badwordsFilter = new Filter();
const minLength = 4;
const maxLength = 15;

exports.sanitizer = functions
    .region('europe-west2')
    .firestore
    .document('/users/{userId}')
    .onWrite((change) => {
        const newUserData = change.after.exists ? change.after.data() : null;

        if (!newUserData || nameValid(newUserData)) {
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
        if (userData.groups === null) {
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

                if (groupData.members === null) {
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
        if (context.auth === null) {
            return {
                status: -200
            };
        }

        const groupId = data.groupId;
        const email = data.email;

        if (email === null || groupId === null) {
            return {
                status: -200
            }
        }
        let user;
        try {
            user = await admin.auth().getUserByEmail(email);
        } catch (e) {
            // Assume user is not found
            return {
                status: -1
            }
        }

        if (user === null) {
            return {
                status: -1
            }
        }

        const group = await admin.firestore().doc(`groups/${groupId}`).get();
        if (group === null) {
            return {
                status: -200
            }
        }

        console.log(`Members in group ${groupId}`);
        console.log(group.data().members);

        const inviter = group.data().members.find((member) => {
            return member.userId === context.auth.uid;
        });

        if (inviter === undefined) {
            console.warn(`Couldn't find ${context.auth.uid} from group ${groupId} even though he's the inviter`);
            return {
                status: -200
            }
        }

        if (inviter.role !== 1) {
            console.log(`${context.auth.uid} is not an admin in group ${groupId}`);
            return {
                status: -2
            }
        }

        const existingMember = group.data().members.find((member) => {
            return member.userId === user.uid;
        });

        if (existingMember !== undefined) {
            console.log(`${user.uid} is already a member of ${groupId}`);
            return {
                status: -3
            }
        }

        const userInvitations = await admin.firestore().doc(`groupInvitations/${user.uid}`).get()
        console.log('User invitations');
        console.log(userInvitations.data());

        if (userInvitations.data() !== undefined &&
            userInvitations.data().groupId !== null &&
            userInvitations.data().groupId !== undefined) {
            console.log(`${user.uid} has already been invited to ${groupId}`);
            return {
                status: -4
            }
        }

        await userInvitations.ref.set({
            groupId: 1
        }, {
            merge: true
        })
        return {
            status: 0,
        };
    });

function nameValid(userData) {
    return userData.displayName !== null &&
        userData.displayName.length >= minLength &&
        userData.displayName.length <= maxLength &&
        userData.displayName === badwordsFilter.clean(userData.displayName);
}