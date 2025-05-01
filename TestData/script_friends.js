const fs = require('fs');

const userCount = 500;
const friendsPerUser = 5;

const getRandomFriends = () => {
  const set = new Set();
  while (set.size < friendsPerUser) {
    set.add(Math.floor(Math.random() * userCount) + 1);
  }
  return Array.from(set);
};

// Prepare CSV content
let csvContent = 'user_id,friend_id\n';

for (let user_id = 1; user_id <= userCount; user_id++) {
  const friends = getRandomFriends();
  friends.forEach(friend => {
    csvContent += `${user_id},${friend}\n`;
  });
}

// Write to file
fs.writeFileSync('user_friends.csv', csvContent);
console.log('CSV file created: user_friends.csv');
