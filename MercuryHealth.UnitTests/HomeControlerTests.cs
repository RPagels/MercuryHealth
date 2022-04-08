//using Microsoft.VisualStudio.TestTools.UnitTesting;
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

//[TestClass]
[TestFixture]
public class HomeControlerTests
{
    private readonly Mock<IFeatureManagerSnapshot> _featureManager;
    private readonly MercuryHealthWebContext _context;
    private readonly Mock<IConfiguration> _config;
    private readonly MockRepository _mockrepository = new MockRepository(MockBehavior.Strict);
    private readonly HomeController _homecontroller;
    //private readonly IOptionsSnapshot<Settings> _settings;

    public HomeControlerTests()
    {
        var builder = new DbContextOptionsBuilder<MercuryHealthWebContext>().UseInMemoryDatabase($"MercuryHealth{Guid.NewGuid()}");
        _context = new MercuryHealthWebContext(builder.Options);
        _featureManager = _mockrepository.Create<IFeatureManagerSnapshot>();
        _config = _mockrepository.Create<IConfiguration>();
        //_homecontroller = new HomeController(_context, _config.Object, _featureManager.Object, _settings);
        _homecontroller = new HomeController(_context, _config.Object, _featureManager.Object);
    }

    //[TestMethod]
    //[TestCategory("UnitTests")]
    [Test]
    [Category("UnitTests")]
    public void DummyTest1()
    {
        Assert.AreEqual(".Net Rocks!", ".Net Rocks!");
    }
    //[TestMethod]
    //[TestCategory("UnitTests")]
    [Test]
    [Category("UnitTests")]
    public void DummyTest2()
    {
        Assert.AreEqual("X", "X");
    }

    //[TestMethod]
    //[TestCategory("UnitTests")]
    [Test]
    [Category("UnitTests")]
    public async Task Privacy_should_return_model_when_true()
    {
        _featureManager.Setup(_fm => _fm.IsEnabledAsync("PrivacyBeta")).Returns(Task.FromResult(true));

        ViewResult result = await _homecontroller.Privacy() as ViewResult;
        var viewName = result.ViewName;
        var model = result.Model as PrivacyModel;

        // checking that homecontroller.index goes to the page
        Assert.IsNotNull(model);
        Assert.AreEqual("Privacy Beta", model.Name);

        _mockrepository.VerifyAll();
    }

    //[TestMethod]
    //[TestCategory("UnitTests")]
    [Test]
    [Category("UnitTests")]
    public async Task Privacy_should_not_return_model_when_false()
    {
        _featureManager.Setup(_fm => _fm.IsEnabledAsync("PrivacyBeta")).Returns(Task.FromResult(false));

        ViewResult result = await _homecontroller.Privacy() as ViewResult;
        var viewName = result.ViewName;
        var model = result.Model as PrivacyModel;

        // checking that homecontroller.index goes to the page
        Assert.IsNotNull(model);
        Assert.AreEqual("Privacy", model.Name);

        _mockrepository.VerifyAll();
    }

    //[TestMethod]
    //[TestCategory("Unit Tests")]
    [Test]
    [Category("UnitTests")]
    public void HomeMetrics()
    {
        //ViewResult result = _homecontroller.Metrics() as ViewResult;
        //var viewName = result.ViewName;

        //// checking that homecontroller.index goes to the page
        //Assert.AreEqual("", viewName);
        //_mockrepository.VerifyAll();
    }

}
