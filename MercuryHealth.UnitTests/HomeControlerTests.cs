using MercuryHealth.Web.Data;
using MercuryHealth.Web.Controllers;
using MercuryHealth.Web.Models;
using Microsoft.FeatureManagement;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Moq;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using NUnit.Framework;
using Microsoft.Extensions.Options;

namespace MercuryHealth.UnitTests;

[TestFixture]
public class HomeControlerTests
{
    private readonly Mock<IFeatureManagerSnapshot> _featureManager;
    private readonly MercuryHealthWebContext _context;
    private readonly Mock<IConfiguration> _config;
    private readonly MockRepository _mockrepository = new MockRepository(MockBehavior.Strict);
    private readonly HomeController _homecontroller;
    private readonly Mock<IOptionsSnapshot<PageSettings>> _pageSettings;

    public HomeControlerTests()
    {
        var builder = new DbContextOptionsBuilder<MercuryHealthWebContext>().UseInMemoryDatabase($"MercuryHealth{Guid.NewGuid()}");
        _context = new MercuryHealthWebContext(builder.Options);
        _featureManager = _mockrepository.Create<IFeatureManagerSnapshot>();
        _config = _mockrepository.Create<IConfiguration>();
        
        _pageSettings = _mockrepository.Create<IOptionsSnapshot<PageSettings>>();
        var myPageSettings = new PageSettings();
        myPageSettings.FontSize = 12;

        //_pageSettings.Setup(x => myPageSettings);
        _pageSettings.Setup(x => x.Value).Returns(myPageSettings);

        _homecontroller = new HomeController(_context, _pageSettings.Object, _config.Object, _featureManager.Object);
    }

    [Test]
    [Category("UnitTests")]
    public void DummyTest()
    {
        Assert.AreEqual(".Net Rocks!", ".Net Rocks!");
    }

    [Test]
    [Category("UnitTests")]
    public async Task Privacy_should_return_model_when_true()
    {
        _featureManager.Setup(_fm => _fm.IsEnabledAsync("PrivacyBeta")).Returns(Task.FromResult(true));

        ViewResult? result = await _homecontroller.Privacy() as ViewResult;
        var viewName = result.ViewName;
        var model = result.Model as PrivacyModel;

        // checking that homecontroller.index goes to the page
        Assert.IsNotNull(model);
        Assert.AreEqual("Privacy Beta", model.Name);

        _mockrepository.VerifyAll();
    }

    [Test]
    [Category("UnitTests")]
    public async Task Privacy_should_not_return_model_when_false()
    {
        _featureManager.Setup(_fm => _fm.IsEnabledAsync("PrivacyBeta")).Returns(Task.FromResult(false));

        ViewResult? result = await _homecontroller.Privacy() as ViewResult;
        var viewName = result.ViewName;
        var model = result.Model as PrivacyModel;

        // checking that homecontroller.index goes to the page
        Assert.IsNotNull(model);
        Assert.AreEqual("Privacy", model.Name);

        _mockrepository.VerifyAll();
    }

    [Test]
    [Category("UnitTests")]
    public async Task Metrics_should_return_model_when_false()
    {
        _featureManager.Setup(_fm => _fm.IsEnabledAsync("MetricsDashboard")).Returns(Task.FromResult(false));

        ViewResult? result = await _homecontroller.Metrics() as ViewResult;
        var viewName = result.ViewName;
        var model = result.Model as MetricsModel;

        // checking that homecontroller.index goes to the page
        //Assert.IsNotNull(model);
        Assert.IsInstanceOf<MetricsModel>(result.Model);
        Assert.AreEqual("Metrics", model.Name);

        _mockrepository.VerifyAll();
    }

    [Test]
    [Category("UnitTests")]
    public async Task Metrics_should_not_return_model_when_false()
    {
        _featureManager.Setup(_fm => _fm.IsEnabledAsync("MetricsDashboard")).Returns(Task.FromResult(false));

        ViewResult? result = await _homecontroller.Metrics() as ViewResult;
        var viewName = result.ViewName;
        var model = result.Model as MetricsModel;

        // checking that homecontroller.index goes to the page
        //Assert.IsNotNull(model);
        Assert.IsInstanceOf<MetricsModel>(result.Model);
        Assert.AreEqual("Metrics", model.Name);

        _mockrepository.VerifyAll();
    }
}
