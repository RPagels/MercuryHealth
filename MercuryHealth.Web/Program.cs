using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using MercuryHealth.Web.Data;
using Microsoft.FeatureManagement;
using Microsoft.Extensions.Azure;
using NuGet.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.FeatureManagement.FeatureFilters;
using MercuryHealth.Web;
using System.Diagnostics;
using Microsoft.Extensions.Configuration.AzureAppConfiguration.FeatureManagement;

var builder = WebApplication.CreateBuilder(args);

//Retrieve the Connection String from the secrets manager 
var connectionString = builder.Configuration.GetConnectionString("AppConfig");

// Add Azure App Configuration/Feature management services to the container.
builder.Host.ConfigureAppConfiguration(builder =>
{
    //Connect to your App Config Store & Load Configurations using the connection string
    builder.AddAzureAppConfiguration(options =>
    {
        options.Connect(connectionString)
        //.UseFeatureFlags(FeatureFlagOptions =>
        //{
        //    FeatureFlagOptions.CacheExpirationInterval = TimeSpan.FromSeconds(10);
        //});
        //.Select("_")  // only load a nonexisting dummy keys
        .ConfigureRefresh(refreshOptions =>
         {
             refreshOptions.Register("MercuryHealth:Settings:Sentinel", refreshAll: true).SetCacheExpiration(TimeSpan.FromSeconds(10));

             // Set Cache timeout for one value only
             //refreshOptions.Register("Settings:MetricsDashboard").SetCacheExpiration(TimeSpan.FromSeconds(10));
         });

    });

});

// Add services to the container.
builder.Services.AddRazorPages();

// Add Azure App Configuration/Feature management services to the container.
builder.Services.AddFeatureManagement();
                //.UseDisabledFeaturesHandler(new CustomDisabledFeatureHandler())
                //.AddFeatureFilter<PercentageFilter>();
                //.AddFeatureFilter<TimeWindowFilter>();

// Bind configuration to the Settings object
builder.Services.Configure<Settings>(builder.Configuration.GetSection("MercuryHealth:Settings"));

// Add DBContext services to the container
builder.Services.AddDbContext<MercuryHealthWebContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MercuryHealthWebContext")));

// Setup Health Probe
builder.Services.AddHealthChecks()
    .AddCheck<MyAppHealthCheck>("Sample")
    .AddDbContextCheck<MercuryHealthWebContext>();

// Add MVC views and Controller services to the container.
builder.Services.AddControllersWithViews();

// Add Azure Application Insights services to the container
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["APPINSIGHTS_CONNECTIONSTRING"]);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Setup Health Probe Endpoint
app.MapHealthChecks("/healthy");

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

// Use Azure App Configuration middleware for dynamic configuration refresh.
//app.UseAzureAppConfiguration();

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

    // Enable middleware to serve generated Swagger as a JSON endpoint.
    app.UseSwagger();

    // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.),
    // specifying the Swagger JSON endpoint.
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
    });

app.Run();
