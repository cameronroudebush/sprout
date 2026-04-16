import CDP from "chrome-remote-interface";
import fs from "fs";
import path from "path";
import sharp from "sharp";

/** Class representing a screenshot route we will want */
class ScreenshotRoute {
  constructor(
    public path: string,
    public store?: { title: string; desc: string },
    public outputName = path.substring(1),
  ) {}

  /** Where we storing the image output when screen-shotted */
  getImagePathOutput(...extraPaths: string[]) {
    return path.join("docs", "images", ...extraPaths, `${this.outputName}.png`);
  }
}

/////
// Configuration options
/////

/** Overarching config of routes we want screenshots of */
const routes = [
  new ScreenshotRoute("/", { title: "Overview", desc: "Your Financial Growth at a Glance" }, "home"),
  new ScreenshotRoute("/accounts"),
  new ScreenshotRoute("/reports", { title: "Insights", desc: "Visualize your spending patterns" }),
  new ScreenshotRoute("/transactions", { title: "Activity", desc: "Every transaction, categorized instantly" }),
  new ScreenshotRoute("/holdings", { title: "Portfolio", desc: "Track your investments effortlessly" }),
  new ScreenshotRoute("/subscriptions"),
  new ScreenshotRoute("/chat", { title: "AI Assistant", desc: "Ask questions, get financial answers" }),
  new ScreenshotRoute("/categories"),
  new ScreenshotRoute("/rules"),
];

/** The display sizes we want to take pictures of */
const viewports = [
  { name: "mobile", width: 375, height: 812, mobile: true },
  { name: "desktop", width: 1920, height: 1080, mobile: false },
];

/////
// Begin functionality
/////

/** Returns the background for our store images */
export async function getBackground(width: number, height: number, layout: "straight" | "right" | "left") {
  // Dynamically angle the gradient to match the layout direction
  let gradX1 = "0%",
    gradY1 = "0%",
    gradX2 = "100%",
    gradY2 = "100%";

  if (layout === "right") {
    gradX1 = "100%";
    gradX2 = "0%";
  } else if (layout === "straight") {
    gradX1 = "50%";
    gradX2 = "50%";
  }

  const svgBuffer = Buffer.from(`
    <svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
      <defs>
        <linearGradient id="bg-grad" x1="${gradX1}" y1="${gradY1}" x2="${gradX2}" y2="${gradY2}">
          <stop offset="0%" stop-color="#001e2c" /> <stop offset="45%" stop-color="#0b3b51" /> <stop offset="100%" stop-color="#116383" /> </linearGradient>

        <filter id="noise">
          <feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="3" stitchTiles="stitch" />
          <feColorMatrix type="matrix" values="
            0.33 0.33 0.33 0 0
            0.33 0.33 0.33 0 0
            0.33 0.33 0.33 0 0
            0 0 0 0.05 0" /> </filter>

        <linearGradient id="grid-grad" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stop-color="white" stop-opacity="0.04" />
          <stop offset="100%" stop-color="white" stop-opacity="0" />
        </linearGradient>
      </defs>

      <rect width="100%" height="100%" fill="url(#bg-grad)" />

      <rect width="100%" height="100%" filter="url(#noise)" pointer-events="none" />
    </svg>
  `);

  return await sharp({
    create: { width, height, channels: 4, background: { r: 0, g: 30, b: 44, alpha: 1 } },
  })
    .composite([{ input: svgBuffer, top: 0, left: 0 }])
    .png()
    .toBuffer();
}

/** Builds a screenshot with some nice highlighting gradient across it with rounded borders */
async function buildScreenshot(screenshot: Buffer, corner: number) {
  const scMeta = await sharp(screenshot).metadata();
  return await sharp(screenshot)
    .composite([
      {
        input: Buffer.from(`
          <svg width="${scMeta.width}" height="${scMeta.height}">
            <defs>
              <linearGradient id="glare" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#ffffff" stop-opacity="0.12"/>
                <stop offset="35%" stop-color="#ffffff" stop-opacity="0.01"/>
              </linearGradient>
            </defs>
            <rect x="0" y="0" width="${scMeta.width}" height="${scMeta.height}" rx="${corner}" ry="${corner}" fill="url(#glare)"/>
          </svg>
        `),
        blend: "over",
      },
      {
        input: Buffer.from(`
          <svg width="${scMeta.width}" height="${scMeta.height}">
            <rect x="0" y="0" width="${scMeta.width}" height="${scMeta.height}" rx="${corner}" ry="${corner}" />
          </svg>
        `),
        blend: "dest-in",
      },
    ])
    .toBuffer();
}

/** This function takes in a screenshot buffer of an app screen shot along with other info and creates a picture intended for the google play store. */
async function createStoreScreenshot(
  screenshotBuffer: Buffer,
  title: string,
  description: string,
  layout: "straight" | "right" | "left" = "straight",
  c = {
    /** Rounding for the screenshotBuffer given */
    corner: 40,
    /** Width for output image */
    width: 1200,
    /** Height for output image */
    height: 1900,
  },
) {
  const background = await getBackground(c.width, c.height, layout);

  // Build the flat screenshot device with shadow
  const resizedScreenshot = await sharp(screenshotBuffer).resize(c.width).toBuffer();
  const flatScreenshot = await buildScreenshot(resizedScreenshot, c.corner);

  // Apply our perspective based on our mode
  const affineMatrix = layout === "right" ? [0.96, 0.08, -0.06, 0.96] : layout === "left" ? [0.96, -0.08, 0.06, 0.96] : [1.0, 0.0, 0.0, 1.0];

  let screenshot = sharp(flatScreenshot);
  if (layout !== "straight") screenshot = screenshot.affine(affineMatrix as any, { background: { r: 0, g: 0, b: 0, alpha: 0 } });
  const safeScreenshot = await screenshot
    .trim()
    .resize({
      width: c.width * 0.9,
      height: c.height * 0.8,
      fit: "inside",
    })
    .toBuffer();
  const screenshotMeta = await sharp(safeScreenshot).metadata();

  // Creates text content for displaying the title and description
  const typography = Buffer.from(`
    <svg width="${c.width}" height="${c.height}">
      <defs>
        <filter id="text-shadow">
          <feDropShadow dx="0" dy="6" stdDeviation="12" flood-color="#000000" flood-opacity="0.5"/>
        </filter>
      </defs>
      <style>
        .headline { 
          fill: white;
          font-size: 110px;
          font-weight: bold;
          font-family: 'Sprout';
        }
        .desc { 
          fill: white; 
          font-size: 52px; 
          font-weight: 600; 
          font-family: 'Sprout';
        }
      </style>
      <text x="50%" y="150" text-anchor="middle" class="headline">${title.toUpperCase()}</text>
      <text x="50%" y="250" text-anchor="middle" class="desc">${description}</text>
    </svg>
  `);

  // Combine the text + the screenshot and write it to a buffer
  return sharp(background)
    .composite([{ input: safeScreenshot, top: c.height * 0.18, left: Math.floor((c.width - screenshotMeta.width) / 2) }, { input: typography }])
    .toBuffer();
}

/** Creates a high-level overview image with the logo and key bullet points */
async function createMainOverview(c = { width: 1200, height: 1900, corner: 20 }) {
  const logoPath = path.join("frontend", "assets", "logo", "color-transparent.png");
  const background = await getBackground(c.width, c.height, "straight");
  const logoWidth = 1000;
  const logoBuffer = await sharp(logoPath).resize({ width: logoWidth, fit: "inside" }).png().toBuffer();
  const overviewWidth = 800;
  const resizedOverview = await sharp(routes[0]!.getImagePathOutput("mobile")).resize({ width: overviewWidth, fit: "inside" }).png().toBuffer();
  const overview = await buildScreenshot(resizedOverview, c.corner);

  const textOverlay = Buffer.from(`
    <svg width="${c.width}" height="${c.height}" xmlns="http://www.w3.org/2000/svg">
      <style>
        .title { fill: white; font-size: 80px; font-weight: bold; font-family: 'Sprout'; }
        .bullet { fill: #4ade80; font-size: 45px; font-weight: bold; font-family: 'Sprout'; }
        .body { fill: #e2e8f0; font-size: 40px; font-family: 'Sprout'; }
      </style>
      <text x="150" y="50" class="bullet">✔</text>
      <text x="220" y="50" class="body">Self-Hostable Finance Tracking</text>
      
      <text x="150" y="150" class="bullet">✔</text>
      <text x="220" y="150" class="body">Crystal-clear Net Worth View</text>
      
      <text x="150" y="250" class="bullet">✔</text>
      <text x="220" y="250" class="body">Full Transaction History</text>
      
      <text x="50%" y="350" text-anchor="middle" class="body" style="font-style: italic; fill: #94a3b8;">
        Your journey to financial growth starts here.
      </text>
    </svg>
  `);

  return sharp(background)
    .composite([
      { input: logoBuffer, top: 50, left: (c.width - logoWidth) / 2 },
      { input: textOverlay, top: 500, left: 0 },
      { input: overview, top: 1000, left: (c.width - overviewWidth) / 2 },
    ])
    .toBuffer();
}

/** Creates the horizontal banner for the main image of Sprout */
async function createHorizontalBanner(
  mainScreenshot: Buffer,
  extraScreenshots: Buffer[],
  logoPath: string,
  playBadgePath: string,
  c = {
    /** Rounding for the screenshotBuffer given */
    corner: 20,
    /** Width of the output image */
    width: 1920,
    /** Height of the output image */
    height: 1080,
  },
) {
  const background = await getBackground(c.width, c.height, "right");
  // Helper to process a card (round corners and ensure PNG)
  const processCard = async (buf: Buffer) => {
    const meta = await sharp(buf).metadata();
    return sharp(buf)
      .composite([
        {
          input: Buffer.from(`
            <svg width="${meta.width}" height="${meta.height}">
              <rect x="0" y="0" width="${meta.width}" height="${meta.height}" rx="${c.corner}" ry="${c.corner}" />
            </svg>
          `),
          blend: "dest-in",
        },
      ])
      .png()
      .toBuffer();
  };

  // Process all screenshots
  const mainCard = await processCard(mainScreenshot);
  const backCard1 = await processCard(extraScreenshots[0]!);
  const backCard2 = await processCard(extraScreenshots[1]!);

  // Rotate the background cards for the "fan" effect
  const card1Rotated = await sharp(backCard1)
    .rotate(-10, { background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .toBuffer();

  const card2Rotated = await sharp(backCard2)
    .rotate(10, { background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .toBuffer();

  // Assets
  const logoBuffer = await sharp(logoPath).resize({ width: 900, fit: "inside" }).png().toBuffer();
  const badgeBuffer = await sharp(playBadgePath).resize({ width: 550, height: 300, fit: "inside" }).png().toBuffer();

  const brandingOverlay = Buffer.from(`
    <svg width="${c.width}" height="${c.height}" xmlns="http://www.w3.org/2000/svg">
      <style>.disclaimer { fill: white; font-size: 18px; font-family: 'Sprout'; }</style>
      <text x="150" y="875" class="disclaimer">*Requires self hosted application</text>
    </svg>
  `);

  // Positioning for card fans
  const xPos = c.width * 0.7;
  const yPos = 180;

  return sharp(background)
    .composite([
      { input: brandingOverlay, top: 0, left: 0 },
      { input: logoBuffer, top: 140, left: 60 },
      { input: badgeBuffer, top: 680, left: 130 },
      { input: card1Rotated, top: yPos, left: xPos - 300 },
      { input: card2Rotated, top: yPos, left: xPos + 40 },
      { input: mainCard, top: yPos + 20, left: xPos - 60 },
    ])
    .toBuffer();
}

/** Iterates through each route and viewport and captures screenshots */
async function captureScreenshots() {
  console.log(`--- Capturing Basic Screenshots ---`);
  let client;
  try {
    // Find the running chrome debug window
    const targets = await CDP.List({ port: 9222 });
    const target = targets.find((t) => t.type === "page" && t.url.includes("8989")) || targets[0];
    if (!target) throw new Error("No valid Chrome tab found!");

    // Setup client for debug window
    client = await CDP({ target });
    const { Page, Runtime, Emulation } = client;
    await Page.enable();

    // Iterate over every viewport and take a screenshot
    for (const viewport of viewports) {
      console.log(`--- Setting Viewport: ${viewport.name} ---`);
      await Emulation.setDeviceMetricsOverride({
        width: viewport.width,
        height: viewport.height,
        deviceScaleFactor: 1,
        mobile: viewport.mobile,
      });

      // Loop over every route to take a picture of it
      for (const route of routes) {
        console.log(`Capturing ${route.path}`);
        // Used to navigate as if we were navigating internally to flutter, to not trigger rebuilds
        await Runtime.evaluate({
          expression: `window.history.pushState({}, '', '${route.path}');
               window.dispatchEvent(new PopStateEvent('popstate'));`,
        });

        // Wait a moment for data to load
        await new Promise((resolve) => setTimeout(resolve, 1000));

        // Capture the data
        const { data } = await Page.captureScreenshot({
          format: "png",
          clip: { x: 0, y: 0, width: viewport.width, height: viewport.height, scale: 1 },
        });
        const buffer = Buffer.from(data, "base64");
        const outputPath = route.getImagePathOutput(viewport.name);

        // Write the file
        if (!fs.existsSync(path.dirname(outputPath))) fs.mkdirSync(path.dirname(outputPath), { recursive: true });
        fs.writeFileSync(outputPath, new Uint8Array(buffer));
      }
    }
  } catch (err) {
    console.error("Error during CDP operation:", err);
  } finally {
    if (client) await client.close();
  }
}

/** Iterates over every route that wants store screenshots and saves them */
async function buildStoreScreenshots() {
  console.log(`--- Building Store Screenshots ---`);
  const storeRoutes = routes.filter((x) => x.store);

  const storeTargetPath = path.join("docs", "images", "store");
  if (!fs.existsSync(storeTargetPath)) fs.mkdirSync(storeTargetPath, { recursive: true });

  for (let i = 0; i < storeRoutes.length; i++) {
    const route = storeRoutes[i]!;
    const asset = route.store!;
    console.log(`Building ${route.path}`);
    // Load the data in from it's mobile viewport counterpart
    const buffer = fs.readFileSync(route.getImagePathOutput("mobile"));

    if (buffer) {
      const style = ["straight", "left", "right"].at(i % 3)!;
      const styledImage = await createStoreScreenshot(buffer, asset.title, asset.desc, style as any);
      const outputPath = route.getImagePathOutput("store");
      if (!fs.existsSync(path.dirname(outputPath))) fs.mkdirSync(path.dirname(outputPath), { recursive: true });
      fs.writeFileSync(outputPath, new Uint8Array(styledImage));
    }
  }

  // Generate marketing banner
  console.log(`--- Generating Marketing Banner ---`);
  const buffers = routes.slice(0, 3).map((x) => fs.readFileSync(x.getImagePathOutput("mobile")));
  fs.writeFileSync(
    path.join("docs", "images", "store", "horizontal.png"),
    new Uint8Array(
      await createHorizontalBanner(
        buffers[0]!,
        buffers.slice(1),
        path.join("frontend", "assets", "logo", "color-transparent.png"),
        path.join("docs", "assets", "google-play.png"),
      ),
    ),
  );

  console.log(`--- Generating Overview ---`);
  // Generate overview main store screenshot
  const overviewBuffer = await createMainOverview();
  const overviewOutputPath = path.join("docs", "images", "store", "overview.png");
  if (!fs.existsSync(path.dirname(overviewOutputPath))) fs.mkdirSync(path.dirname(overviewOutputPath), { recursive: true });
  fs.writeFileSync(overviewOutputPath, new Uint8Array(overviewBuffer));
}

/** The main app */
async function main() {
  await captureScreenshots();
  await buildStoreScreenshots();
  console.log("Screenshots captured and saved successfully");
}

main();
