LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
WITH collect(row) AS rows
UNWIND range(0, size(rows)-1) AS i
WITH rows[i] AS row, i + 1 as id
CREATE (:Person {id: id, name: row.name, age: row.age});


LOAD CSV WITH HEADERS FROM 'file:///dishes.csv' AS row
WITH collect(row) AS rows
UNWIND range(0, size(rows)-1) AS i
WITH rows[i] AS row, i + 1 as id
CREATE (:Dish {id: id, name: row.name, cuisine: row.cuisine});


LOAD CSV WITH HEADERS FROM 'file:///restaurants.csv' AS row
WITH collect(row) AS rows
UNWIND range(0, size(rows)-1) AS i
WITH rows[i] AS row, i + 1 as id
CREATE (:Restaurant {id: id, name: row.name, cuisine: row.cuisine});


LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row
OPTIONAL MATCH (p:Person {id: toInteger(row.user_id)})
OPTIONAL MATCH (d:Dish {id: toInteger(row.dish_id)})
FOREACH (_ IN CASE WHEN p IS NOT NULL AND d IS NOT NULL THEN [1] ELSE [] END |
  CREATE (p)-[:ATE {rating: toInteger(row.rating)}]->(d)
)

LOAD CSV WITH HEADERS FROM 'file:///visits.csv' AS row
WITH toInteger(row.user_id) AS uid, toInteger(row.country_id) AS cid
OPTIONAL MATCH (p:Person {id: uid})
OPTIONAL MATCH (c:Country {id: cid})
FOREACH (_ IN CASE WHEN p IS NOT NULL AND c IS NOT NULL THEN [1] ELSE [] END |
  CREATE (p)-[:VISITED {visit: 1}]->(c)
)

LOAD CSV WITH HEADERS FROM 'file:///dish_restaurant_price.csv' AS row
WITH toInteger(row.dish_id) AS did, toInteger(row.restaurant_id) AS rid , oInteger(row.price) AS price
OPTIONAL MATCH (d:Dish {id: did})
OPTIONAL MATCH (r:Restaurant {id: rid})
FOREACH (_ IN CASE WHEN d IS NOT NULL AND r IS NOT NULL THEN [1] ELSE [] END |
  CREATE (d)-[:SERVED_AT {price: price}]->(r)
)


LOAD CSV WITH HEADERS FROM 'file:///user_friends.csv' AS row
WITH toInteger(row.user_id) AS uid, toInteger(row.friend_id) AS fid
OPTIONAL MATCH (u:Person {id: uid})
OPTIONAL MATCH (f:Person {id: fid})
FOREACH (_ IN CASE WHEN u IS NOT NULL AND f IS NOT NULL THEN [1] ELSE [] END |
  CREATE (u)-[:FRIENDS_WITH {friend: true}]->(f)
)







// SEQUENTIAL QUERY
MATCH (me:Person {name: "Isaac"})

MATCH (me)-[r:ATE]->(likedDish:Dish)
WHERE r.rating >= 7

WITH me, collect(DISTINCT likedDish.cuisine) AS preferredCuisines

OPTIONAL MATCH (me)-[:FRIENDS_WITH]->(friend:Person)-[fr:ATE]->(friendDish:Dish)
WHERE fr.rating >= 7

OPTIONAL MATCH (me)-[:VISITED]->(country:Country)
OPTIONAL MATCH (visitedRest:Restaurant)-[:LOCATED_IN]->(country)<-[:VISITED]-(me)
OPTIONAL MATCH (visitedDish:Dish)-[:SERVED_AT]->(visitedRest)

MATCH (dish:Dish)-[:SERVED_AT]->(rest:Restaurant)
WHERE NOT (me)-[:ATE]->(dish)

WITH DISTINCT dish, rest, me,
     CASE WHEN dish.cuisine IN preferredCuisines THEN 2 ELSE 0 END AS cuisineScore,
     COUNT(DISTINCT CASE WHEN friendDish = dish THEN friendDish ELSE NULL END) AS friendScore,
     COUNT(DISTINCT CASE WHEN visitedDish = dish THEN visitedDish ELSE NULL END) AS countryScore

WITH dish, rest, (cuisineScore + friendScore + countryScore) AS totalScore
ORDER BY totalScore DESC, rand()

RETURN dish.name AS recommended_dish,
       dish.cuisine AS cuisine,
       rest.name AS restaurant,
       rest.id AS restaurant_id,
       totalScore
LIMIT 10





















// ISOLATED QUERY
MATCH (me:Person {name: "Isaac"})
WITH me

CALL {
  WITH me
  MATCH (me)-[r:ATE]->(d:Dish)
  WHERE r.rating >= 7
  RETURN collect(DISTINCT d.cuisine) AS preferredCuisines
}

CALL {
  WITH me
  MATCH (me)-[:FRIENDS_WITH]->(:Person)-[r:ATE]->(d:Dish)
  WHERE r.rating >= 7
  RETURN collect(DISTINCT d) AS friendLikedDishes
}

CALL {
  WITH me
  MATCH (me)-[:VISITED]->(c:Country)<-[:LOCATED_IN]-(r:Restaurant)<-[:SERVED_AT]-(d:Dish)
  RETURN collect(DISTINCT d) AS visitedDishes
}

MATCH (d:Dish)-[:SERVED_AT]->(r:Restaurant)
WHERE NOT (me)-[:ATE]->(d)

WITH d, r, preferredCuisines, friendLikedDishes, visitedDishes,
     CASE WHEN d.cuisine IN preferredCuisines THEN 2 ELSE 0 END AS cuisineScore,
     CASE WHEN d IN friendLikedDishes THEN 1 ELSE 0 END AS friendScore,
     CASE WHEN d IN visitedDishes THEN 1 ELSE 0 END AS countryScore

WITH d, r, (cuisineScore + friendScore + countryScore) AS totalScore
ORDER BY totalScore DESC, rand()
LIMIT 10

RETURN d.name AS recommended_dish,
       d.cuisine AS cuisine,
       r.name AS restaurant,
       totalScore
