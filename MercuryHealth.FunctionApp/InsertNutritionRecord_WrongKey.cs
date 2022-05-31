using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace MercuryHealth.FunctionApp;

public class InsertNutritionRecord_WrongKey
{
    private static string ApimSubscriptionKey = System.Environment.GetEnvironmentVariable("ApimSubscriptionKey");
    private static string ApimWebServiceURL = System.Environment.GetEnvironmentVariable("ApimWebServiceURL");

    // TESTING ONLY
    //private static string WebAppUrl = System.Environment.GetEnvironmentVariable("WebAppUrl");

    [FunctionName("InsertNutritionRecord_WrongKey")]
    public async Task RunAsync([TimerTrigger("0 0 */12 * * *")] TimerInfo myTimer, ILogger log)
    {
        // Time Trigger Cheat Sheet: https://codehollow.com/2017/02/azure-functions-time-trigger-cron-cheat-sheet/
        // 0 * * * * *	    every minute
        // 0 */5 * * * *	every 5 minutes
        // 0 0 */6 * * *	every 6 hours

        var client = new HttpClient();
        var queryString = HttpUtility.ParseQueryString(string.Empty);

        // Request headers with APIM Key retrieved from Azure KeyVault
        client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ApimSubscriptionKey + "BadKey");

        //var uri = "https://rpagels-apim.azure-api.net/api/Nutritions?" + queryString;
        //var uri = WebAppUrl + "api/Nutritions?" + queryString;
        var uri = ApimWebServiceURL + "/api/Nutritions?" + queryString;

        HttpResponseMessage response;

        string serializedObject = Newtonsoft.Json.JsonConvert.SerializeObject(new
        {
            id = "0",
            description = "Kiwi",
            quantity = "1",
            mealTime = DateTime.Now,
            tags = "API Update",
            calories = "42",
            proteinInGrams = "0.8",
            fatInGrams = "0.4",
            carbohydratesInGrams = "10",
            sodiumInGrams = "2",
            color = "Brown"
        });

        // Request body
        byte[] byteData = Encoding.UTF8.GetBytes(serializedObject);

        using (var content = new ByteArrayContent(byteData))
        {
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            response = await client.PostAsync(uri, content);

            // Get the JSON response.
            string contentString = await response.Content.ReadAsStringAsync();

            // Display the JSON response.
            Console.WriteLine("\nResponse:\n");
            Console.WriteLine(contentString);

        }
    }
}
