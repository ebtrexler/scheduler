const AWS = require("aws-sdk");

const APPTS_TABLE = process.env.APPTS_TABLE;
const dynamoDbClient = new AWS.DynamoDB.DocumentClient();

module.exports.getAllUserAppts = async (event) => {

  const body = JSON.parse(event.body); //JSON.parse(Buffer.from(event.body, 'base64').toString())
  const userId = body.email;

  const params = {
    TableName: APPTS_TABLE,
    FilterExpression: '#userId = :userId',
    ExpressionAttributeNames: {
      '#userId': 'userId',
    },
    ExpressionAttributeValues: {
      ':userId': userId,
    },
  };


  try {
    const result = await dynamoDbClient.scan(params).promise();
    if (result.Count === 0) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: "No appts found for user: " + userId
        })
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        total: result.Count,
        items: await result.Items.map(appt => {
          return {
            primaryKey: appt.primaryKey,
            userId: appt.userId,
            name: appt.name,
            dateTimeField: appt.dateTimeField,
            location: appt.location,
            guests: appt.guests
          }
        })
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


// module.exports.createOrUpdateAppt = async (event) => {
//   const body = JSON.parse(event.body); //JSON.parse(Buffer.from(event.body, 'base64').toString())

//   const item = {
//     primary_key: body.dataId,
//     userId: body.userId,
//     name: body.name,
//     datetime: body.datetime,
//     location: body.location,
//     guests: body.guests,
//   };
//   console.log(item);

//   const params = {
//     TableName: APPTS_TABLE,
//     Item: item,
//   };

//   try {
//     await dynamoDbClient.put(params).promise();
//     return {
//       statusCode: 200,
//       body: JSON.stringify(body),
//     };
//   } catch (error) {
//     console.log(error);
//     return {
//       statusCode: 500,
//       error: "Could not create appointment"
//     };
//   }
// };

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
