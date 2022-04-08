using Microsoft.EntityFrameworkCore;
using MercuryHealth.Web.Data;
using Microsoft.FeatureManagement;
using Microsoft.FeatureManagement.FeatureFilters;
using MercuryHealth.Web;
using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);

//Retrieve the Connection String from the secrets manager 
var connectionString = builder.Configuration.GetConnectionString("AppConfig");

// Add Azure App Configuration/Feature management services to the container.
//builder.Host.ConfigureAppConfiguration(builder =>
//{
//    //Connect to your App Config Store & Load Configurations using the connection string
//    builder.AddAzureAppConfiguration(options =>
//    {
//        options.Connect(connectionString)
//        .ConfigureRefresh(refreshOptions =>
//         {
//             refreshOptions.Register("Settings:Sentinel", refreshAll: true).SetCacheExpiration(TimeSpan.FromMinutes(1));

//             // Optional - Set Cache timeout for one value only
//             //refreshOptions.Register("Settings:MetricsDashboard").SetCacheExpiration(TimeSpan.FromSeconds(10));
//         });

//    });

//});

    builder.Host.ConfigureAppConfiguration(builder =>
    {
            //Connect to your App Config Store using the connection string
            builder.AddAzureAppConfiguration(options =>
        {
            options.Connect(connectionString)
                    .UseFeatureFlags()
                    .ConfigureRefresh(refresh =>
                    {
                        refresh.Register("App:Settings:Sentinel", refreshAll: true)
                            .SetCacheExpiration(new TimeSpan(0, 0, 30)); //TimeSpan.FromSeconds(10)
                    });
        });
    })
    .ConfigureServices(services =>
    {
        // Add MVC views and Controller services to the container.
        services.AddControllersWithViews();
    });

// Works great!!!
//builder.Host.ConfigureAppConfiguration(builder =>
//    {
//        //Connect to your App Config Store using the connection string
//        builder.AddAzureAppConfiguration(connectionString);
//    })
//        .ConfigureServices(services =>
//        {
//            // Add MVC views and Controller services to the container.
//            services.AddControllersWithViews();
//        });

// Bind configuration to the Settings object
builder.Services.Configure<NuGet.Configuration.Settings>(builder.Configuration.GetSection("App:Settings"));
builder.Services.AddAzureAppConfiguration();

// Add Azure App Configuration/Feature management services to the container.
builder.Services.AddFeatureManagement()
                .UseDisabledFeaturesHandler(new CustomDisabledFeatureHandler())
                .AddFeatureFilter<PercentageFilter>()
                .AddFeatureFilter<TimeWindowFilter>();

// Add DBContext services to the container
builder.Services.AddDbContext<MercuryHealthWebContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MercuryHealthWebContext")));

// Setup Health Probe
builder.Services.AddHealthChecks()
    .AddCheck<MyAppHealthCheck>("Sample")
    .AddDbContextCheck<MercuryHealthWebContext>();

// Add services to the container.
builder.Services.AddRazorPages();

// Add MVC views and Controller services to the container.
//builder.Services.AddControllersWithViews();

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
app.UseAzureAppConfiguration();
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
