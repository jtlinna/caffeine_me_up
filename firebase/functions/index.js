const functions = require('firebase-functions');
const Filter = require('bad-words');

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
        
        if(!newUserData || nameValid(newUserData)) {
            return null;
        }
        
        const oldUserdata = change.before.exists ? change.before.data() : null;
        const name = oldUserdata !== null && oldUserdata.displayName !== null ? oldUserdata.displayName : 'User';

        console.log(`Sanitizing name ${newUserData.displayName} to ${name}`);
        console.log(newUserData);
        const sanitizedData = {...newUserData, displayName: name };
        console.log(sanitizedData);
        
        return change.after.ref.update(sanitizedData);
    });

function nameValid(userData) {
    return userData.displayName !== null &&
        userData.displayName.length >= minLength &&
        userData.displayName.length <= maxLength &&
        userData.displayName === badwordsFilter.clean(userData.displayName);
}