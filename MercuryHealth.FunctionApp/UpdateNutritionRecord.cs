using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using MercuryHealth.Web.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace MercuryHealth.FunctionApp;

public class UpdateNutritionRecord
{
    private static string ApimSubscriptionKey = System.Environment.GetEnvironmentVariable("ApimSubscriptionKey");

    //private readonly TelemetryClient telemetry;

    //public UpdateNutritionRecord(TelemetryClient telemetry)
    //{
    //    this.telemetry = telemetry;
    //}

    [FunctionName("UpdateNutritionRecord")]
    //public void Run([TimerTrigger("0 */5 * * * *")]TimerInfo myTimer, ILogger log)
    public async Task RunAsync([TimerTrigger("0 */10 * * * *")] TimerInfo myTimer, ILogger log)
    {

        try
        {
            // Instantiate new record object
            Nutrition nutrition;

            // https://rpagels-apim.azure-api.net/api/Nutritions/{id}
            var client = new HttpClient();

            // Request headers
            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ApimSubscriptionKey);

            // Hard code record # 25
            var uri = "https://rpagels-apim.azure-api.net/api/Nutritions/25";

            var response = await client.GetAsync(uri);
            response.EnsureSuccessStatusCode();
            string responseBody = await response.Content.ReadAsStringAsync();

            // Deserialize JSON Object to Nutrition record
            nutrition = Newtonsoft.Json.JsonConvert.DeserializeObject<Nutrition>(responseBody);

            // Update a couple fields
            nutrition.Tags = "API Update";
            nutrition.MealTime = DateTime.Now;

            // Serialize JSON Object from Nutrition record
            string serializedObjectUpdated = Newtonsoft.Json.JsonConvert.SerializeObject(nutrition);

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
            //telemetry.TrackEvent("TrackEvent-Nutrition API Update " + nutrition.Id.ToString() + " " + nutrition.Description);

        }
        catch (Exception)
        {
            throw;
        }

    }
}