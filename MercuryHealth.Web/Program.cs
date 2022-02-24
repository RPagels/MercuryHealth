using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using MercuryHealth.Web.Data;
using Microsoft.FeatureManagement;
using Microsoft.Extensions.Azure;
using NuGet.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.FeatureManagement.FeatureFilters;
using MercuryHealth.Web;

var builder = WebApplication.CreateBuilder(args);

//Retrieve the Connection String from the secrets manager 
var connectionString = builder.Configuration.GetConnectionString("AppConfig");

builder.Host.ConfigureAppConfiguration(builder =>
{
    //Connect to your App Config Store & Load Configurations using the connection string
    builder.AddAzureAppConfiguration(options =>
    {
        options.Connect(connectionString)
        .ConfigureRefresh(refreshOptions =>
         {
             refreshOptions.Register("MercuryHealth:Settings:Sentinel", refreshAll: true).SetCacheExpiration(TimeSpan.FromSeconds(10));

             // Set Cache timeout for one value only
             //refresh.Register("Settings:MetricsDashboard").SetCacheExpiration(TimeSpan.FromSeconds(10));
         });

        // Use Feature Flags
        //.UseFeatureFlags(featureFlagOptions =>
        //{
        //    featureFlagOptions.CacheExpirationInterval = TimeSpan.FromSeconds(15);
        //});
    });
});


// Add services to the container.
builder.Services.AddRazorPages();

// Add Azure App Configuration and feature management services to the container.
builder.Services.AddFeatureManagement()
                .UseDisabledFeaturesHandler(new CustomDisabledFeatureHandler())
                .AddFeatureFilter<PercentageFilter>()
                .AddFeatureFilter<TimeWindowFilter>();

// Bind configuration to the Settings object
builder.Services.Configure<Settings>(builder.Configuration.GetSection("MercuryHealth:Settings"));

// Add DBContext services to the container
builder.Services.AddDbContext<MercuryHealthWebContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MercuryHealthWebContext")));

// Add MVC views and Controller services to the container.
builder.Services.AddControllersWithViews();

// Add Azure Application Insights services to the container
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["APPINSIGHTS_CONNECTIONSTRING"]);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

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

app.Run();
