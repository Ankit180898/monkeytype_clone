const axios = require('axios');

exports.handler = async function(event, context) {
  try {
    // The API key is secure here - only on Netlify's servers
    const apiKey = process.env.API_KEY;
    
    // Get query parameters
    const params = event.queryStringParameters || {};
    
    // Make request to the actual API
    const response = await axios.get('https://quotes15.p.rapidapi.com/quotes/random/', {
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'quotes15.p.rapidapi.com'
      },
      params: params  // Forward any query parameters
    });

    // Return the data to your client
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(response.data)
    };
  } catch (error) {
    return {
      statusCode: error.response?.status || 500,
      body: JSON.stringify({ 
        error: error.message,
        content: "The quick brown fox jumps over the lazy dog",
        originator: { name: "Default" }
      })
    };
  }
};