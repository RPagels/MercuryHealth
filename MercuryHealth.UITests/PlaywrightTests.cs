using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Playwright;
using NUnit.Framework;

namespace MercuryHealth.UITests

{
    [Parallelizable(ParallelScope.Self)]
    public class PlaywrightTests
    {
        [OneTimeSetUp]
        public void Init()
        {
            // The following line installs the default browsers. If you only need a subset of browsers,
            // you can specify the list of browsers you want to install among: chromium, chrome,
            // chrome-beta, msedge, msedge-beta, msedge-dev, firefox, and webkit.
            // var exitCode = Microsoft.Playwright.Program.Main(new[] { "install", "webkit", "chrome" });
            var exitCode = Microsoft.Playwright.Program.Main(new[] { "install", "chromium", "msedge", "firefox" });
            if (exitCode != 0)
            {
                throw new Exception($"Playwright exited with code {exitCode}");
            }
        }

        [SetUp]
        //[OneTimeSetUp]
        public void Setup()
        {
            // The following line installs the default browsers. If you only need a subset of browsers,
            // you can specify the list of browsers you want to install among: chromium, chrome,
            // chrome-beta, msedge, msedge-beta, msedge-dev, firefox, and webkit.
            // var exitCode = Microsoft.Playwright.Program.Main(new[] { "install", "webkit", "chrome" });
            //var exitCode = Microsoft.Playwright.Program.Main(new[] { "install", "chromium", "msedge", "firefox" });
            //if (exitCode != 0)
            //{
            //    throw new Exception($"Playwright exited with code {exitCode}");
            //}
        }

        [Test]
        [Category("Playwright_Tests")]
        public void Playwright_Dummy()
        {
            Assert.Pass();
        }

        string myPageTitle = "";
        //string pageURL = "https://website-4vwxkvpofrtbq-dev.azurewebsites.net/";
        string pageURL = AppHelpers.GetURL();


        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToHome()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "Home-Homepage.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "Home-Homepage.png"), "Home-Homepage.png");

            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToNutrition()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

            await page.ClickAsync("#menu_nutrition");
            myPageTitle = await page.TitleAsync();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "Nutrition-Homepage.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "Nutrition-Homepage.png"), "Nutrition-Homepage.png");

            Assert.AreEqual("Nutrition - Mercury Health", myPageTitle);

            // Click text=Home
            await page.ClickAsync("text=Home");

        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToNutritionDetail()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

            await page.ClickAsync("#menu_nutrition");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Nutrition - Mercury Health", myPageTitle);

            // Click #button_details_25
            await page.ClickAsync("#button_details_25");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Details - Mercury Health", myPageTitle);

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "nutrition_details_25.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "nutrition_details_25.png"), "nutrition_details_25.png");

            Assert.AreEqual(pageURL + "Nutritions/Details/25", page.Url);

            string myDescription = await page.TextContentAsync("id=Description");
            myDescription = myDescription.Replace("\n", string.Empty);
            //myDescription = myDescription.Replace(" ", string.Empty);
            myDescription = myDescription.TrimStart();
            myDescription = myDescription.TrimEnd();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "Item-Description.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "Item-Description.png"), "Item-Description.png");

            // Randomize a failure
            //Random rnd = new Random();
            //if (rnd.Next(1, 2) == 1) // creates a number between 1 and 2
            //{
            //    Assert.AreEqual("Banana", myDescription, "Expected title to be 'Banana'");
            //}
            //else
            //{
            //    Assert.AreEqual("Strawberry", myDescription, "Expected title to be 'Strawberry'");
            //}

            // Assert that field
            Assert.AreEqual("Banana", myDescription);

            // Click text=Home
            await page.ClickAsync("text=Home");

        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToNutritionEdit()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

            await page.ClickAsync("#menu_nutrition");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Nutrition - Mercury Health", myPageTitle);

            // Click #button_edit_25
            await page.ClickAsync("#button_edit_25");

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "nutrition_edit_25.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "nutrition_edit_25.png"), "nutrition_edit_25.png");

            Assert.AreEqual(pageURL + "Nutritions/Edit/25", page.Url);

            // Click input[name="Tags"]
            await page.FillAsync("input[name=\"Tags\"]", "Playwright is Fun");

            // Click text=Save
            await page.ClickAsync("text=Save");

            // Click #button_details_25
            await page.ClickAsync("#button_details_25");

            Assert.AreEqual(pageURL + "Nutritions/Details/25", page.Url);

            string myDescription = await page.TextContentAsync("id=Tags");
            myDescription = myDescription.Replace("\n", string.Empty);
            //myDescription = myDescription.Replace(" ", string.Empty);
            myDescription = myDescription.TrimStart();
            myDescription = myDescription.TrimEnd();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "nutrition_editcheck_25.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "nutrition_editcheck_25.png"), "nutrition_editcheck_25.png");

            // Assert that field
            Assert.AreEqual("Playwright is Fun", myDescription);

            // Click text=Back to List
            //await page.ClickAsync("text=Back to List");
            await page.ClickAsync("#button_back");

            // Click #button_edit_25
            await page.ClickAsync("#button_edit_25");
            Assert.AreEqual(pageURL + "Nutritions/Edit/25", page.Url);

            // Click input[name="Tags"]
            await page.FillAsync("input[name=\"Tags\"]", "fruit, snack");

            // Click text=Save
            await page.ClickAsync("text=Save");

            // Click text=Home
            await page.ClickAsync("text=Home");
        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToExercises()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

            await page.ClickAsync("#menu_exercises");
            myPageTitle = await page.TitleAsync();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "Exercises-Homepage.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "Exercises-Homepage.png"), "Exercises-Homepage.png");

            Assert.AreEqual("Exercises - Mercury Health", myPageTitle);

            // Click text=Home
            await page.ClickAsync("text=Home");

        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToExercisesDetail()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

            await page.ClickAsync("#menu_exercises");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Exercises - Mercury Health", myPageTitle);

            // Click #button_details_25
            await page.ClickAsync("#button_details_25");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Details - Mercury Health", myPageTitle);

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "exercises_details_25.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "exercises_details_25.png"), "exercises_details_25.png");

            Assert.AreEqual(pageURL + "Exercises/Details/25", page.Url);

            string myDescription = await page.TextContentAsync("id=Muscles");
            myDescription = myDescription.Replace("\n", string.Empty);
            //myDescription = myDescription.Replace(" ", string.Empty);
            myDescription = myDescription.TrimStart();
            myDescription = myDescription.TrimEnd();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "Item-Description.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "Item-Description.png"), "Item-Description.png");

            // Assert that field is API Update!!!
            //Assert.AreEqual("API Update", myDescription);
            Assert.AreEqual("Legs", myDescription);

            // Click text=Back to List
            //await page.ClickAsync("text=Back to List");
            await page.ClickAsync("#button_back");

            // Click #button_edit_25
            await page.ClickAsync("#button_edit_25");
            Assert.AreEqual(pageURL + "Exercises/Edit/25", page.Url);

            // Click input[name="MusclesInvolved"]
            await page.FillAsync("input[name=\"MusclesInvolved\"]", "Playwright Testing");

            // Click text=Save
            await page.ClickAsync("text=Save");

            // Click text=Home
            await page.ClickAsync("text=Home");

        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_NavToExercisesEdit()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

            await page.ClickAsync("#menu_exercises");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Exercises - Mercury Health", myPageTitle);

            // Click #button_edit_25
            await page.ClickAsync("#button_edit_25");
            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Edit - Mercury Health", myPageTitle);

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "exercises_edit_25.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "exercises_edit_25.png"), "exercises_edit_25.png");

            Assert.AreEqual(pageURL + "Exercises/Edit/25", page.Url);

            // Click input[name="Tags"]
            await page.FillAsync("input[name=\"MusclesInvolved\"]", "Playwright is Fun");

            // Click text=Save
            await page.ClickAsync("text=Save");

            // Click #button_details_25
            await page.ClickAsync("#button_details_25");

            Assert.AreEqual(pageURL + "Exercises/Details/25", page.Url);

            string myDescription = await page.TextContentAsync("id=Muscles");
            myDescription = myDescription.Replace("\n", string.Empty);
            //myDescription = myDescription.Replace(" ", string.Empty);
            myDescription = myDescription.TrimStart();
            myDescription = myDescription.TrimEnd();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "exercises_editcheck_25.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "exercises_editcheck_25.png"), "exercises_editcheck_25.png");

            // Assert that field
            Assert.AreEqual("Playwright is Fun", myDescription);

            await page.ClickAsync("#button_back");

            // Click #button_edit_25
            await page.ClickAsync("#button_edit_25");
            Assert.AreEqual(pageURL + "Exercises/Edit/25", page.Url);

            // Click input[name="MusclesInvolved"]
            await page.FillAsync("input[name=\"MusclesInvolved\"]", "Legs");

            // Click text=Save
            await page.ClickAsync("text=Save");

            // Click text=Home
            await page.ClickAsync("text=Home");

        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_PlaywrightPageTitle()
        {
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            page.SetDefaultTimeout(30000);
            await page.GotoAsync("https://playwright.dev/dotnet");

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Fast and reliable end-to-end testing for modern web apps | Playwright .NET", myPageTitle);

            //await page.WaitForLoadStateAsync(state: LoadState.DOMContentLoaded);

            //var currentTheme = await page.GetAttributeAsync("html", "data-theme");
            //await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "before-theme-change.png"), await page.ScreenshotAsync());
            //await page.ClickAsync("[class='react-toggle-track']");
            //var changedTheme = await page.GetAttributeAsync("html", "data-theme");
            //Assert.AreNotEqual(currentTheme, changedTheme, $"Theme did not change");
            //await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "after-theme-change.png"), await page.ScreenshotAsync());

            //TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "before-theme-change.png"), "before-theme-change.png");
            //TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "after-theme-change.png"), "after-theme-change.png");
        }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_Bing()
        {
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            page.SetDefaultTimeout(30000);
            await page.GotoAsync("https://www.bing.com");

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Bing", myPageTitle);

         }

        [Test]
        [Category("Playwright_Tests_Chromium")]
        public async Task Verify_Google()
        {
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            page.SetDefaultTimeout(30000);
            await page.GotoAsync("https://www.google.com");

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Google", myPageTitle);

        }

        [Test]
        [Category("Playwright_Tests_FireFox")]
        public async Task Verify_BingOnFirefox()
        {
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            page.SetDefaultTimeout(30000);
            await page.GotoAsync("https://www.bing.com");

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Bing", myPageTitle);

        }

        [Test]
        [Category("Playwright_Tests_FireFox")]
        public async Task Verify_GoogleOnFirefox()
        {
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            page.SetDefaultTimeout(30000);
            await page.GotoAsync("https://www.google.com");

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Google", myPageTitle);

        }
    }
}

