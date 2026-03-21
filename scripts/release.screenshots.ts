import CDP from "chrome-remote-interface";
import fs from "fs";
import path from "path";

/** Routes that we want to process and take screenshots of and the file to name them */
const routes = [
  { path: "/", output: "home" },
  { path: "/accounts", output: "accounts" },
  { path: "/transactions", output: "transactions" },
  { path: "/reports", output: "reports" },
  { path: "/holdings", output: "holdings" },
  { path: "/subscriptions", output: "subscriptions" },
  { path: "/chat", output: "chat" },
  { path: "/categories", output: "categories" },
  { path: "/rules", output: "rules" },
];

/** The device sizes we want to use */
const viewports = [
  { name: "mobile", width: 375, height: 812, mobile: true },
  { name: "desktop", width: 1920, height: 1080, mobile: false },
];

/** The main app that iterates through the routes and captures screenshots */
async function main() {
  /** Docs path to place images */
  const targetPath = path.join("docs", "images");
  let client;
  try {
    // Find the specific tab running the app
    const targets = await CDP.List({ port: 9222 });
    // Look for a target that matches your localhost prot and page
    const target = targets.find((t) => t.type === "page" && t.url.includes("8989")) || targets[0];

    if (!target) throw new Error("No valid Chrome tab found!");

    // Gather chrome client data
    client = await CDP({ target });
    const { Page, Runtime, Emulation } = client;
    await Page.enable();

    for (const viewport of viewports) {
      console.log(`--- Setting Viewport: ${viewport.name} ---`);

      // Apply the screen size for this specific pass
      await Emulation.setDeviceMetricsOverride({
        width: viewport.width,
        height: viewport.height,
        deviceScaleFactor: 1,
        mobile: viewport.mobile,
      });

      for (const route of routes) {
        console.log(`Capturing ${route.path}`);

        //  Navigate to the page using internal routing
        await Runtime.evaluate({
          expression: `window.history.pushState({}, '', '${route.path}'); 
               window.dispatchEvent(new PopStateEvent('popstate'));`,
        });

        // Give Flutter a moment to render the frame
        await new Promise((resolve) => setTimeout(resolve, 600));

        // Capture the screenshot based on sizing
        const { data } = await Page.captureScreenshot({
          format: "png",
          clip: { x: 0, y: 0, width: viewport.width, height: viewport.height, scale: 1 },
        });

        // Write out the screenshot
        const fileName = `${route.output}.png`;
        const filePath = path.join(targetPath, viewport.name, fileName);
        fs.writeFileSync(filePath, new Uint8Array(Buffer.from(data, "base64")));
      }
    }
  } catch (err) {
    console.error("Error during CDP operation:", err);
  } finally {
    if (client) await client.close();
  }
}

// Run the main function
main();
