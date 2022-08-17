//using System;
//using System.Net.Http;
//using System.Net.Http.Headers;
//using System.Text;
//using System.Threading.Tasks;
//using MercuryHealth.Web.Models;
//using Microsoft.ApplicationInsights;
//using Microsoft.Azure.WebJobs;
//using Microsoft.Extensions.Logging;

//namespace MercuryHealth.FunctionApp;

//public class UpdateNutritionRecord_BadRequest
//{
//    private static string ApimSubscriptionKey = System.Environment.GetEnvironmentVariable("ApimSubscriptionKey");
//    private static string ApimWebServiceURL = System.Environment.GetEnvironmentVariable("ApimWebServiceURL");

//    private readonly TelemetryClient telemetry;

//    public UpdateNutritionRecord_BadRequest(TelemetryClient telemetry)
//    {
//        this.telemetry = telemetry;
//    }

//    [FunctionName("UpdateNutritionRecord_BadRequest")]
//    public async Task RunAsync([TimerTrigger("0 */7 * * * *")] TimerInfo myTimer, ILogger log)
//    {

//        try
//        {
//            // Instantiate new record object
//            //Nutrition nutrition;

//            var client = new HttpClient();

//            // Request headers
//            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", ApimSubscriptionKey);

//            // Hard code record # 25
//            var uri = ApimWebServiceURL + "/api/Nutritions/25";
//            log.LogInformation($"uri: {uri}");

//            //var response = await client.GetAsync(uri);
//            //response.EnsureSuccessStatusCode();
//            //string responseBody = await response.Content.ReadAsStringAsync();
//            //DateTime payLoadDateTime = DateTime.Now;
//            string payLoadDateTime = Newtonsoft.Json.JsonConvert.SerializeObject(DateTime.Now);
//            //JsonSerializer.Serialize(DateTime.Now);

//            //string payLoad = "{\"id\":25,\"description\":\"string\",\"quantity\":0,\"mealTime\":\"2022-04-04T00:00:00\",\"tags\":\"string\",\"calories\":\"X\",\"proteinInGrams\":0,\"fatInGrams\":0,\"carbohydratesInGrams\":0,\"sodiumInGrams\":0,\"color\":\"string\"}";
//            string payLoad = "{\"id\":25,\"description\":\"Banana\",\"quantity\":1,\"mealTime\":payLoadDateTime,\"tags\":\"API Update\",\"calories\":\"O\",\"proteinInGrams\":1.3,\"fatInGrams\":0.4,\"carbohydratesInGrams\":0.12,\"sodiumInGrams\":1.20,\"color\":\"Yellow\"}";

//            // Deserialize JSON Object to Nutrition record
//            //nutrition = Newtonsoft.Json.JsonConvert.DeserializeObject<Nutrition>(responseBody);

//            // Update a fields
//            //nutrition.Tags = "API Update";
//            //nutrition.ProteinInGrams = Convert.ToDecimal("0.123456");
//            //nutrition.MealTime = DateTime.Now;

//            // Serialize JSON Object from Nutrition record
//            //string serializedObjectUpdated = Newtonsoft.Json.JsonConvert.SerializeObject(nutrition);

//            // Request body
//            byte[] byteData = Encoding.UTF8.GetBytes(payLoad);

//            using (var content = new ByteArrayContent(byteData))
//            {
//                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
//                var response = await client.PutAsync(uri, content);

//                // Get the JSON response.
//                string contentString = await response.Content.ReadAsStringAsync();

//                // Display the JSON response.
//                Console.WriteLine("\nResponse:\n");
//                Console.WriteLine(contentString);

//            }

//            // Application Insights - Track Events
//            telemetry.TrackEvent("TrackEvent-Nutrition API Update 25 - Banana");

//        }
//        catch (Exception)
//        {
//            throw;
//        }

//    }
//}
