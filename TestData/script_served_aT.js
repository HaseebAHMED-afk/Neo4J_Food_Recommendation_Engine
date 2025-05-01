const fs = require('fs');

const dishCount = 1000;
const restaurantCount = 100;
const assignmentsPerDish = 5;

const getRandomPrice = () => Math.floor(Math.random() * 100) + 1;
const getRandomRestaurants = () => {
  const set = new Set();
  while (set.size < assignmentsPerDish) {
    set.add(Math.floor(Math.random() * restaurantCount) + 1);
  }
  return Array.from(set);
};

// Prepare CSV content
let csvContent = 'dish_id,restaurant_id,price\n';

for (let dishId = 1; dishId <= dishCount; dishId++) {
  const restaurants = getRandomRestaurants();
  restaurants.forEach(restaurantId => {
    const price = getRandomPrice();
    csvContent += `${dishId},${restaurantId},${price}\n`;
  });
}

// Write to file
fs.writeFileSync('dish_restaurant_price.csv', csvContent);
console.log('CSV file created: dish_restaurant_price.csv');
