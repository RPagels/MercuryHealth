using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using MercuryHealth.Web.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace MercuryHealth.FunctionApp;

public class UpdateExerciseRecord
{
    private static string ApimSubscriptionKey = System.Environment.GetEnvironmentVariable("ApimSubscriptionKey");

    // TESTING ONLY
   // private static string WebAppUrl = System.Environment.GetEnvironmentVariable("WebAppUrl");

    //private readonly TelemetryClient telemetry;

    //public UpdateNutritionRecord(TelemetryClient telemetry)
    //{
    //    this.telemetry = telemetry;
    //}

    [FunctionName("UpdateExerciseRecord")]
    public async Task RunAsync([TimerTrigger("0 */20 * * * *")] TimerInfo myTimer, ILogger log)
    {

        try
        {
            // Instantiate new record object
            Exercises exercise;

            // https://rpagels-apim.azure-api.net/api/Exercises/{id}
            var client = new HttpClient();

            // Request headers
            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ApimSubscriptionKey);

            // Hard code record # 25
            var uri = "https://rpagels-apim.azure-api.net/api/Exercises/25";
            //var uri = WebAppUrl + "api/Exercises/25";

            var response = await client.GetAsync(uri);
            response.EnsureSuccessStatusCode();
            string responseBody = await response.Content.ReadAsStringAsync();

            log.LogInformation($"responseBody: {responseBody}");

            // Deserialize JSON Object to Exercise record
            exercise = Newtonsoft.Json.JsonConvert.DeserializeObject<Exercises>(responseBody);

            // Update a couple fields
            exercise.Name = "API Update";
            exercise.MusclesInvolved = "API Update";
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
            //telemetry.TrackEvent("TrackEvent-Exercise API Update " + exercise.Name.ToString() + " " + exercise.Description);

        }
        catch (Exception)
        {
            throw;
        }

    }
}

