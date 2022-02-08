using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using MercuryHealth.Web.Data;
using Microsoft.FeatureManagement;
using Microsoft.Extensions.Azure;
using NuGet.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

var builder = WebApplication.CreateBuilder(args);

//Retrieve the Connection String from the secrets manager 
var connectionString = builder.Configuration.GetConnectionString("AppConfig");

//builder.Host.ConfigureAppConfiguration(builder =>
//{
//    //Connect to your App Config Store using the connection string
//    builder.AddAzureAppConfiguration(connectionString);

//});

builder.Host.ConfigureAppConfiguration(builder =>
{
    //Connect to your App Config Store using the connection string
    builder.AddAzureAppConfiguration(options =>
    {
        options.Connect(connectionString)
        // Load all keys that start with `WebDemo:` and have no label
        //.Select("WebDemo:*")
        .ConfigureRefresh(refreshOptions =>
         {
             refreshOptions.Register("Settings:EnableMetricsDashboard", refreshAll: true);
             // Set Cache timeout for one value only
             //refresh.Register("Settings:EnableMetricsDashboard").SetCacheExpiration(TimeSpan.FromSeconds(10));
         })
        .UseFeatureFlags(featureFlagOptions =>
        {
            featureFlagOptions.CacheExpirationInterval = TimeSpan.FromSeconds(20);
        });
    });
});


// ////////////////////////////////////////////////////
// Load configuration from Azure App Configuration
//builder.Configuration.AddAzureAppConfiguration(options =>
//{
//    //options.Connect(Environment.GetEnvironmentVariable("AppConfig"))
//    options.Connect(connectionString)
//           // Load all keys that start with `WebDemo:` and have no label
//           //.Select("WebDemo:*")
//           .Select("*:*")
//           // Configure to reload configuration if the registered key 'WebDemo:Sentinel' is modified.
//           // Use the default cache expiration of 30 seconds. It can be overriden via AzureAppConfigurationRefreshOptions.SetCacheExpiration.
//           .ConfigureRefresh(refreshOptions =>
//           {
//               refreshOptions.Register("Settings:EnableMetricsDashboard", refreshAll: true);
//           })
//           // Load all feature flags with no label. To load specific feature flags and labels, set via FeatureFlagOptions.Select.
//           // Use the default cache expiration of 30 seconds. It can be overriden via FeatureFlagOptions.CacheExpirationInterval.
//           //.UseFeatureFlags();
//           .UseFeatureFlags(featureFlagOptions =>
//            {
//                featureFlagOptions.CacheExpirationInterval = TimeSpan.FromSeconds(20);
//            })

//            .ConfigureRefresh(refresh =>
//            {
//                        // Set Cache timeout for one value only
//                        refresh.Register("Settings:EnableMetricsDashboard").SetCacheExpiration(TimeSpan.FromSeconds(10));
//            });

//});
// ////////////////////////////////////////////////////////////


// Add services to the container.
builder.Services.AddRazorPages();

// Add Azure App Configuration and feature management services to the container.
builder.Services.AddAzureAppConfiguration()
                .AddFeatureManagement();

// Bind configuration to the Settings object
builder.Services.Configure<Settings>(builder.Configuration.GetSection("MercuryHealth:Settings"));

// Add DBContext services to the container
builder.Services.AddDbContext<MercuryHealthWebContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MercuryHealthWebContext")));

// Add MVC views and Controller services to the container.
builder.Services.AddControllersWithViews();

// Add Azure Application Insights services to the container
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["APPINSIGHTS_CONNECTIONSTRING"]);

//builder.Services.AddAzureAppConfiguration(builder.Configuration["AppConfig"]

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

// Use Azure App Configuration middleware for dynamic configuration refresh.
app.UseAzureAppConfiguration();

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
