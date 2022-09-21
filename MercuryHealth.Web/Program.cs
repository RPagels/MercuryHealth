using Microsoft.EntityFrameworkCore;
using MercuryHealth.Web.Data;
using Microsoft.FeatureManagement;
using Microsoft.FeatureManagement.FeatureFilters;
using MercuryHealth.Web;
using MercuryHealth.Web.Controllers;
using Azure.Identity;
using System.Configuration;
using Microsoft.OpenApi.Models;
using Microsoft.ApplicationInsights.Extensibility;

var builder = WebApplication.CreateBuilder(args);

//Retrieve the Connection String from the secrets manager 
var connectionString = builder.Configuration.GetConnectionString("AppConfig");

// Add Azure App Configuration/Feature management services to the container.
builder.Host.ConfigureAppConfiguration(builder =>
    {
            // Connect to your App Config Store using the connection string
            builder.AddAzureAppConfiguration(options =>
        {
            options.Connect(connectionString)
                    .UseFeatureFlags();
                    //.ConfigureRefresh(refresh =>
                    //{
                    //    refresh.Register("App:Settings:Sentinel", refreshAll: true)
                    //        .SetCacheExpiration(TimeSpan.FromSeconds(30));
                    //});
        });
    })
    .ConfigureServices(services =>
    {
        // Add MVC views and Controller services to the container.
        services.AddControllersWithViews();
});

//builder.Services.Configure<ForwardedHeadersOptions>(options =>
//{
//    options.KnownProxies.Add(IPAddress)
//})


// Add services to the container.
builder.Services.AddFeatureManagement(); 
builder.Services.Configure<PageSettings>(builder.Configuration.GetSection("App:Settings"));
builder.Services.AddRazorPages();
builder.Services.AddAzureAppConfiguration();

// Bind configuration to the Settings object
//builder.Services.AddAzureAppConfiguration(); 
//builder.Services.Configure<NuGet.Configuration.Settings>(builder.Configuration.GetSection("App:Settings"));

// Add Azure App Configuration/Feature management services to the container.
//builder.Services.AddFeatureManagement();
                //.UseDisabledFeaturesHandler(new CustomDisabledFeatureHandler())
                //.AddFeatureFilter<PercentageFilter>()
                //.AddFeatureFilter<TimeWindowFilter>();

// Add DBContext services to the container
builder.Services.AddDbContext<MercuryHealthWebContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MercuryHealthWebContext")));

// Setup Health Probe
builder.Services.AddHealthChecks()
    .AddCheck<MyAppHealthCheck>("Sample")
    .AddDbContextCheck<MercuryHealthWebContext>();

//builder.Services.AddSingleton<ITelemetryInitializer, CloneIPAddress>();
//builder.Services.AddSingleton<ITelemetryInitializer, AddAppVersion>();

// Add Azure Application Insights services to the container
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
//builder.Services.AddSwaggerGen();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "MercuryHealth API", Version = "v1" });
});

var app = builder.Build();

// Use Azure App Configuration middleware for dynamic configuration refresh.
app.UseAzureAppConfiguration();

// Setup Health Probe Endpoint
app.MapHealthChecks("/healthy");

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

// NEW - IP Address
app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = Microsoft.AspNetCore.HttpOverrides.ForwardedHeaders.XForwardedFor |
    Microsoft.AspNetCore.HttpOverrides.ForwardedHeaders.XForwardedFor
});

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
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Mercury Health API v1");
    });

app.Run();
