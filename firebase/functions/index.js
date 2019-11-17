const functions = require('firebase-functions');
const Filter = require('bad-words');
const admin = require('firebase-admin');
admin.initializeApp();

const badwordsFilter = new Filter();
const minLength = 4;
const maxLength = 15;


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
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
        const sanitizedData = { ...newUserData, displayName: name };
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

function nameValid(userData) {
    return userData.displayName !== null &&
        userData.displayName.length >= minLength &&
        userData.displayName.length <= maxLength &&
        userData.displayName === badwordsFilter.clean(userData.displayName);
}