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

public class InsertExerciseRecord_WrongKey
{
    private static string ApimSubscriptionKey = Environment.GetEnvironmentVariable("ApimSubscriptionKey");
    private static string ApimWebServiceURL = Environment.GetEnvironmentVariable("ApimWebServiceURL");

    [FunctionName("InsertExerciseRecord_WrongKey")]
    public async Task RunAsync([TimerTrigger("0 0 */6 * * *")] TimerInfo myTimer, ILogger log)
    {
        // Time Trigger Cheat Sheet: https://codehollow.com/2017/02/azure-functions-time-trigger-cron-cheat-sheet/
        // 0 * * * * *	    every minute
        // 0 */5 * * * *	every 5 minutes
        // 0 0 */6 * * *	every 6 hours

        //log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

        var client = new HttpClient();
        var queryString = HttpUtility.ParseQueryString(string.Empty);

        // Request headers with APIM Key retrieved from Azure KeyVault
        client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ApimSubscriptionKey + "BadKey");

        var uri = ApimWebServiceURL + "/api/Exercises?" + queryString;

        HttpResponseMessage response;

        string serializedObject = Newtonsoft.Json.JsonConvert.SerializeObject(new
        {
            id = "0",
            name = "Running/Jogging",
            description = "Build strong bones and improves cardiovascular.",
            ExerciseTime = DateTime.Now,
            musclesInvolved = "Legs",
            equipment = "None"
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
