const AWS = require("aws-sdk");

const USERS_TABLE = process.env.USERS_TABLE;
const dynamoDbClient = new AWS.DynamoDB.DocumentClient();

// this is a stub for a login function
// -- if in the database, then "authenticated"
module.exports.getUser = async (event) => {

  const body = JSON.parse(event.body);
  const params = {
    TableName: USERS_TABLE,
    Key: {
      email: body.email,
    },
  };

  console.log(params);

  try {
    const { Item } = await dynamoDbClient.get(params).promise();
    if (Item) {
      console.log(Item);
      return {
        statusCode: 200,
        body: JSON.stringify({
          email: Item.email,
          name: Item.name,
        })
      };
    } else {
      console.log("error could not find user");
      return {
        statusCode: 404,
        error: 'Could not find user with email = ' + userId
      };
    };


  } catch (error) {
    console.log(error);
    return {
      statusCode: 500,
      error: 'Could not retrieve user'
    };
  }
};

module.exports.getAllUsers = async (event) => {

  const params = {
    TableName: USERS_TABLE
  }

  const result = await dynamoDbClient.scan(params).promise()

  console.log(result);

  if (result.Count === 0) {
    return {
      statusCode: 404,
      error: "There are no users in the database."
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({
      total: result.Count,
      items: await result.Items.map(user => {
        return {
          email: user.email,
          name: user.name
        }
      })
    })
  };
};

module.exports.createOrUpdateUser = async (event) => {

  const body = JSON.parse(event.body); //JSON.parse(Buffer.from(event.body, 'base64').toString())

  const item = {
    email: body.email,
    name: body.name,
  };
  console.log(item);

  const params = {
    TableName: USERS_TABLE,
    Item: item,
  };

  try {
    await dynamoDbClient.put(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({
        email: item.email,
        name: item.name,
      })
    };
  } catch (error) {
    console.log(error);
    return {
      statusCode: 500,
      error: "Could not create user"
    };
  }
};
