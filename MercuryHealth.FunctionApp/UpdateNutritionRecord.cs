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

public class UpdateNutritionRecord
{
    private static string ApimSubscriptionKey = System.Environment.GetEnvironmentVariable("ApimSubscriptionKey");
    private static string ApimWebServiceURL = System.Environment.GetEnvironmentVariable("ApimWebServiceURL");

    private readonly TelemetryClient telemetry;

    public UpdateNutritionRecord(TelemetryClient telemetry)
    {
        this.telemetry = telemetry;
    }

    [FunctionName("UpdateNutritionRecord")]
    public async Task RunAsync([TimerTrigger("0 */5 * * * *")] TimerInfo myTimer, ILogger log)
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
            var uri = ApimWebServiceURL + "/api/Nutritions/25";
            log.LogInformation($"uri: {uri}");

            var response = await client.GetAsync(uri);
            response.EnsureSuccessStatusCode();
            string responseBody = await response.Content.ReadAsStringAsync();
            DateTime payLoadDateTime = DateTime.Now;

            // Deserialize JSON Object to Nutrition record
            nutrition = Newtonsoft.Json.JsonConvert.DeserializeObject<Nutrition>(responseBody);

            // Update a fields
            nutrition.Tags = "API PUT Update";
            nutrition.ProteinInGrams = Convert.ToDecimal("0.123456");
            nutrition.Calories = 110;
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
            telemetry.TrackEvent("TrackEvent-Nutrition API PUT Update " + nutrition.Id.ToString() + " " + nutrition.Description);

        }
        catch (Exception)
        {
            throw;
        }

    }
}
