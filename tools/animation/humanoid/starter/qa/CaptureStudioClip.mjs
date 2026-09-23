/**
 * Capture frames from a real unpublished Studio Play-session Animator.
 *
 * Usage:
 *   node CaptureStudioClip.mjs <studio-id> <clip-name> <output-folder>
 *
 * The tool reads the installed Roblox Chat Bridge's Studio MCP client.
 * It does not modify DungeonMMO gameplay, a source rig, or a file in Git.
 */
import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const DURATION_SECONDS = Object.freeze({
    Idle: 2.0,
    Walk: 1.0,
    Run: 0.7,
    Sword: 1.2,
    Daggers: 1.2,
    Bow: 1.5,
});
const FRAME_COUNT = 12;
const TEST_RIG = "DMMO_Humanoid_Starter_Test";
const GENERATOR = "DMMO_Humanoid_Starter_Generator";

/**
 * Load an MCP client from the user's installed, authorized Studio bridge.
 *
 * Args:
 *     None.
 *
 * Returns:
 *     Promise<object>: Started Studio client with a stop() method.
 */
async function connectToStudio() {
    const runtime = path.join(
        process.env.LOCALAPPDATA, "RobloxChatBridge", "src",
    );
    const clientUrl = pathToFileURL(
        path.join(runtime, "mcp-client.mjs"),
    ).href;
    const mainUrl = pathToFileURL(
        path.join(runtime, "main.mjs"),
    ).href;
    const [{ McpClient }, { findStudioMcpExecutable }] =
        await Promise.all([import(clientUrl), import(mainUrl)]);
    const client = new McpClient({
        executablePath: findStudioMcpExecutable(process.env.LOCALAPPDATA),
        requestTimeoutMs: 28000,
    });
    await client.start();
    return client;
}

/**
 * Verify the exact unpublished test Studio session before any action.
 *
 * Args:
 *     client (object): Connected Studio MCP client.
 *     studioId (string): Exact Studio session ID.
 *
 * Returns:
 *     Promise<void>: Rejects if the target is not the named Place1.
 */
async function verifyStudio(client, studioId) {
    const response = await client.callTool("list_roblox_studios", {});
    const result = JSON.parse(
        response.content.find((item) => item.type === "text").text,
    );
    const matching = result.studios.find((studio) =>
        studio.id === studioId && studio.name === "Place1");
    if (!matching) {
        throw new Error("The requested unpublished Place1 is unavailable");
    }
}

/**
 * Produce a single Lua pose command without touching approved gameplay.
 *
 * Args:
 *     clip (string): Name of one authored test-only humanoid clip.
 *     seconds (number): Playback time in seconds.
 *     isFirst (boolean): Whether the preview track must be started.
 *
 * Returns:
 *     string: Luau to evaluate on the current isolated R15 mannequin.
 */
function poseCommand(clip, seconds, isFirst) {
    const first = isFirst
        ? `track = builder.Play("${clip}"); task.wait(0.10)`
        : `local tracks = animator:GetPlayingAnimationTracks();
           track = tracks[1]`;
    return `
        local rig = workspace:FindFirstChild("${TEST_RIG}")
        assert(game.PlaceId == 0 and rig
            and rig:GetAttribute("DMMO_TestOnly"),
            "An unpublished independent R15 mannequin is required")
        local builder = require(rig.${GENERATOR})
        local animator = rig.Humanoid.Animator
        local track
        ${first}
        assert(track and track.IsPlaying, "No preview track is playing")
        track:AdjustSpeed(0)
        track.TimePosition = ${seconds.toFixed(6)}
        if not game:GetService("RunService"):IsRunning() then
            animator:StepAnimations(0)
        end
        if "${clip}" == "Bow" then
            local arrow = rig:FindFirstChild("DMMO_TestArrow")
            if arrow then
                arrow.Transparency = ${seconds.toFixed(6)} >= 1.05 and 1 or 0
            end
        end
        task.wait(0.025)
        return {
            time = track.TimePosition,
            leftFoot = rig.LeftFoot.Position.Y,
            rightFoot = rig.RightFoot.Position.Y
        }
    `;
}

/**
 * Evaluate one pose and capture the actual Roblox Studio viewport image.
 *
 * Args:
 *     client (object): Authorized Studio MCP client.
 *     studioId (string): Explicit unpublished Place1 identifier.
 *     clip (string): Name of animation to capture.
 *     frame (number): Zero-based sample number.
 *     folder (string): Existing local image output folder.
 *
 * Returns:
 *     Promise<object>: Actual sampled time and saved image metadata.
 */
async function captureFrame(client, studioId, clip, frame, folder) {
    const seconds = frame * DURATION_SECONDS[clip] / FRAME_COUNT;
    const executed = await client.callTool("execute_luau", {
        studio_id: studioId,
        datamodel_type: "Server",
        code: poseCommand(clip, seconds, frame === 0),
    });
    if (executed.isError) {
        throw new Error(`Pose ${clip} frame ${frame}: ${JSON.stringify(
            executed.content,
        ).slice(0, 900)}`);
    }
    const isMoving = clip === "Walk" || clip === "Run";
    const capture = await client.callTool("screen_capture", {
        studio_id: studioId,
        capture_id: `DMMO_${clip}_${frame}`,
        camera_position: isMoving ? [6.2, 3.7, 0] : [5, 4, -7],
        look_at_position: [0, 2.8, 0],
    });
    const image = capture.content?.find((item) => item.type === "image");
    if (capture.isError || !image) {
        throw new Error(`Screen capture failed: ${clip} frame ${frame}`);
    }
    const filename = path.join(
        folder, `${clip}_${String(frame).padStart(2, "0")}.jpg`,
    );
    fs.writeFileSync(filename, Buffer.from(image.data, "base64"));
    return { filename, seconds };
}

/**
 * Release the preview track so the mannequin returns to its idle pose.
 *
 * Args:
 *     client (object): Studio MCP client used for the preview.
 *     studioId (string): The same explicitly selected Studio session.
 *
 * Returns:
 *     Promise<void>: Verifies that the test track was stopped.
 */
async function resetPreview(client, studioId) {
    const response = await client.callTool("execute_luau", {
        studio_id: studioId,
        datamodel_type: "Server",
        code: `
            local rig = workspace:FindFirstChild("${TEST_RIG}")
            assert(rig and game.PlaceId == 0)
            require(rig.${GENERATOR}).Stop()
            return "Preview reset"
        `,
    });
    if (response.isError) {
        throw new Error("Could not reset the experimental test rig");
    }
}

/**
 * Sample one full animation and save the real Studio viewport frames.
 *
 * Args:
 *     None.
 *
 * Returns:
 *     Promise<void>: Saves PNG-independent JPEG frames and a QA manifest.
 */
async function main() {
    const [studioId, clip, outputRoot] = process.argv.slice(2);
    if (!studioId || !DURATION_SECONDS[clip] || !outputRoot) {
        throw new Error("Usage: node CaptureStudioClip.mjs "
            + "<studio-id> <clip-name> <output-folder>");
    }
    const folder = path.join(outputRoot, clip);
    fs.mkdirSync(folder, { recursive: true });
    const client = await connectToStudio();
    const frames = [];
    try {
        await verifyStudio(client, studioId);
        for (let frame = 0; frame < FRAME_COUNT; frame += 1) {
            frames.push(
                await captureFrame(client, studioId, clip, frame, folder),
            );
            console.log("CAPTURE_OK", clip, frame);
        }
    } finally {
        try {
            await resetPreview(client, studioId);
        } finally {
            await client.stop();
        }
    }
    const manifest = {
        clip,
        frameCount: FRAME_COUNT,
        durationSeconds: DURATION_SECONDS[clip],
        sampleType: "real unpublished Studio Play server Animator playback",
        frames,
        visualApproval: "pending user review",
    };
    fs.writeFileSync(
        path.join(folder, "capture_manifest.json"),
        JSON.stringify(manifest, null, 2),
        "utf8",
    );
    console.log("CAPTURE_FINISHED", clip, folder);
}

main().catch((error) => {
    console.error("CAPTURE_FAILED", error.message);
    process.exitCode = 1;
});
