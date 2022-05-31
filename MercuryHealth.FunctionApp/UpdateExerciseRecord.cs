using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using MercuryHealth.Web.Models;
using Microsoft.ApplicationInsights;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace MercuryHealth.FunctionApp;

public class UpdateExerciseRecord
{
    private static string ApimSubscriptionKey = System.Environment.GetEnvironmentVariable("ApimSubscriptionKey");
    private static string ApimWebServiceURL = System.Environment.GetEnvironmentVariable("ApimWebServiceURL");

    private readonly TelemetryClient telemetry;

    public UpdateExerciseRecord(TelemetryClient telemetry)
    {
        this.telemetry = telemetry;
    }

    // Time Trigger Cheat Sheet: https://codehollow.com/2017/02/azure-functions-time-trigger-cron-cheat-sheet/
    // 0 * * * * *	    every minute
    // 0 */5 * * * *	every 5 minutes
    // 0 0 */6 * * *	every 6 hours
    //
    [FunctionName("UpdateExerciseRecord")]
    public async Task RunAsync([TimerTrigger("0 */5 * * * *")] TimerInfo myTimer, ILogger log)
    {

        try
        {
            // Instantiate new record object
            Exercises exercise;

            var client = new HttpClient();

            // Request headers
            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ApimSubscriptionKey);

            // Hard code record # 25
            var uri = ApimWebServiceURL + "/api/Exercises/25";

            log.LogInformation($"uri: {uri}");

            var response = await client.GetAsync(uri);
            response.EnsureSuccessStatusCode();
            string responseBody = await response.Content.ReadAsStringAsync();

            log.LogInformation($"responseBody: {responseBody}");

            // Deserialize JSON Object to Exercise record
            exercise = Newtonsoft.Json.JsonConvert.DeserializeObject<Exercises>(responseBody);

            // Update a couple fields
            //exercise.Name = "API Update";
            exercise.Equipment = "API Update";
            exercise.ExerciseTime = DateTime.Now;

            // Serialize JSON Object from Nutrition record
            string serializedObjectUpdated = Newtonsoft.Json.JsonConvert.SerializeObject(exercise);

            // Request body
            byte[] byteData = Encoding.UTF8.GetBytes(serializedObjectUpdated);

            using (var content = new ByteArrayContent(byteData))
            {
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                response = await client.PutAsync(uri, content);

                // Get the JSON response.
                string contentString = await response.Content.ReadAsStringAsync();

                // Display the JSON response.
                Console.WriteLine("\nResponse:\n");
                Console.WriteLine(contentString);

            }

            // Application Insights - Track Events
            telemetry.TrackEvent("TrackEvent-Exercise API Update " + exercise.Name.ToString() + " " + exercise.Description);

        }
        catch (Exception)
        {
            throw;
        }

    }
}

