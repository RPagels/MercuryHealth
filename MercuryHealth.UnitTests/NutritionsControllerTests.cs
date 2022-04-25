using MercuryHealth.Web.Api;
using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NUnit.Framework;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace MercuryHealth.UnitTests;

[TestFixture]
public class NutritionsControllerTests
{
    private TelemetryClient _telemetryClient;
    private readonly MercuryHealthWebContext _context;

    public NutritionsControllerTests()
    {
        var builder = new DbContextOptionsBuilder<MercuryHealthWebContext>().UseInMemoryDatabase($"MercuryHealth{Guid.NewGuid()}");
        _context = new MercuryHealthWebContext(builder.Options);

        var telemetryConfig = new TelemetryConfiguration { DisableTelemetry = true };
        _telemetryClient = new TelemetryClient(telemetryConfig);
    }

    [Test]
    [Category("UnitTests")]
    public async Task Post_Nutrition_Should_Persist_New_Nutrition() 
    {
        var nutrition = new Nutrition { Id = 1, Description = "My Nutrition" };
        var subject = new NutritionsController(_context, _telemetryClient);
        var result = await subject.PostNutrition(nutrition);

        Assert.IsInstanceOf<CreatedAtActionResult>(result.Result);
        
        var foundNutrition = _context.Nutrition.FirstOrDefault(n => n.Id == 1);
        Assert.IsNotNull(foundNutrition);
        Assert.True(foundNutrition.Description == nutrition.Description);
    }

    [Test]
    [Category("UnitTests")]
    public async Task Delete_Nutrition_Should_Return_Not_Found_When_Id_Does_Not_Exist()
    {
        var subject = new NutritionsController(_context, _telemetryClient);
        var result = await subject.DeleteNutrition(int.MinValue);

        Assert.IsInstanceOf<NotFoundResult>(result.Result);
    }

    [Test]
    [Category("UnitTests")]
    public async Task Delete_Nutrition_Should_Remove_Database_Entry()
    {
        var nutrition = new Nutrition { Id = 1, Description = "My Nutrition" };
        _context.Nutrition.Add(nutrition);
        _context.SaveChanges();
        var subject = new NutritionsController(_context, _telemetryClient);
        var result = await subject.DeleteNutrition(nutrition.Id);

        Assert.IsInstanceOf<OkObjectResult>(result.Result);
        var foundNutrition = _context.Nutrition.FirstOrDefault(n => n.Id == 1);
        Assert.IsNull(foundNutrition);
    }

    [SetUp]
    public void BeforeTest()
    {
        _context.Database.EnsureDeleted();
        _context.Database.EnsureCreated();
    }
}
