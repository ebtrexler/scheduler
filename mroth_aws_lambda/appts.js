const AWS = require("aws-sdk");

const APPTS_TABLE = process.env.APPTS_TABLE;
const dynamoDbClient = new AWS.DynamoDB.DocumentClient();

module.exports.getAllUserAppts = async (event) => {

  const body = JSON.parse(event.body); //JSON.parse(Buffer.from(event.body, 'base64').toString())
  const userId = body.email;
  const userName = body.name;

  // get all appts that user has created
  const ownedParams = {
    TableName: APPTS_TABLE,
    FilterExpression: '#userId = :userId',
    ExpressionAttributeNames: {
      '#userId': 'userId',
    },
    ExpressionAttributeValues: {
      ':userId': userId,
    },
  };

  const invitedParams = {
    TableName: APPTS_TABLE,
    FilterExpression: "contains (guests, :guest)",
    ExpressionAttributeValues: {
      ':guest': userName,
    }
  }

  try {
    const ownedResult = await dynamoDbClient.scan(ownedParams).promise();
    const invitedResult = await dynamoDbClient.scan(invitedParams).promise();

    if (ownedResult.Count === 0 && invitedResult.Count === 0) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: "No appts found for user: " + userId
        })
      };
    }

    var ownedAppts = await ownedResult.Items.map(appt => {
      return {
        primaryKey: appt.primaryKey,
        userId: appt.userId,
        name: appt.name,
        dateTimeField: appt.dateTimeField,
        location: appt.location,
        guests: appt.guests
      }
    });

    var invitedAppts = await invitedResult.Items.map(appt => {
      return {
        primaryKey: appt.primaryKey,
        userId: appt.userId,
        name: appt.name,
        dateTimeField: appt.dateTimeField,
        location: appt.location,
        guests: appt.guests
      }
    })

    return {
      statusCode: 200,
      body: JSON.stringify({
        totalOwned: ownedResult.Count,
        totalInvited: invitedResult.Count,
        items: {
          owned: ownedAppts,
          invited: invitedAppts,
        }
      })
    }


  } catch (error) {
    console.log(error);
    return {
      statusCode: 500,
      error: 'Could not retrieve appts'
    };
  }
};

module.exports.createOrUpdateAppt = async (event) => {
  const body = JSON.parse(event.body); //JSON.parse(Buffer.from(event.body, 'base64').toString())

  console.log(body);

  const params = {
    TableName: APPTS_TABLE,
    Item: body,
  };

  try {
    await dynamoDbClient.put(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(body)
    };
  } catch (error) {
    console.log(error);
    return {
      statusCode: 500,
      error: "Could not create or update appointment\n" + error,
    };
  }
};

module.exports.deleteAppt = async (event) => {
  const body = JSON.parse(event.body); //JSON.parse(Buffer.from(event.body, 'base64').toString())

  console.log(body);

  var params = {
    Key: {
      primaryKey: body.primaryKey
    },
    TableName: APPTS_TABLE,
  };

  try {
    await dynamoDbClient.delete(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(body)
    };
  } catch (error) {
    console.log(error);
    return {
      statusCode: 500,
      error: "Could not delete appointment\n" + error,
    };
  }
};
