# URSS Vibe Coding Practical Guide

## Build Your Own Endpoints and Production Workflows with AI

**Built with AI. Grown by Creators.**

URSS is a platform where creators can do more than use the features provided out of the box. They can modify existing Endpoints or develop entirely new ones.

This guide shares the approach to human–AI collaboration that TeamGadget has used throughout the development journey from GEC to URSS. It is intended to be approachable even if you have little programming experience. Rather than teaching advanced coding techniques, it focuses on **defining specifications, sharing information with AI, and testing things in real applications**.

This approach does not guarantee that everyone will achieve the same results. Think of it as one practical example, and adapt whichever parts suit your own environment.

### Development Environment Used for This Guide

This guide is based on TeamGadget's actual development environment.

- **AI:** ChatGPT (GPT-5.6 Sol)
- **Plan:** ChatGPT Plus
- **Reasoning setting:** Highest available level
- **Workflow:** Discuss the work with AI in a dedicated chat, ask it to create or modify code, and verify the results in the actual application
- **Scope:** Modifying existing URSS Endpoints, adding features, and developing new Endpoints

You do not need to use the same model or plan. A code editor such as Visual Studio is helpful, but not essential. You can also develop by downloading the files created by AI, backing up the originals, replacing them, and testing the results.

---

## Step 1: Create a Dedicated Development Thread

First, create a separate chat (thread) for each development project.

**The key is to keep that thread focused on development, without unrelated conversations.**

As development progresses, the chat accumulates specifications, design decisions, implementation progress, error logs, and records of changes. Keeping unrelated topics out makes it much easier to look back at what was decided and what has been verified.

If a long-running project needs to move to a new thread, ask AI to prepare a handover document covering the finalized specifications, completed phases, unresolved issues, and next steps.

## Step 2: Share Development Documentation and Source Code with AI

Before writing any code, help AI understand the existing system.

For URSS Endpoint development, you will generally want to share:

- **G-HUB Endpoint development documentation** (communication specifications, connection rules, etc.)
- **The source code of the Endpoint you want to work on**
- Relevant configuration files, supported application versions, and the current working state

After sharing the materials, ask AI to summarize the code structure, how the components work together, and which parts may need to change. **Do not start coding yet.**

For URSS, the expectation is that you use the distributed G-HUB application together with its development documentation. Even when working with publicly available Endpoint source code, respect each file's license, modification and redistribution conditions, and the boundaries of non-public components.

## Step 3: Define the Specifications Before You Start Coding

**This step is especially important.**

Explain what you want to build, then discuss possible implementations, their impact on existing features, and potential problems with AI. Be open about what you want, and ask AI to suggest alternatives or point out concerns. Work through the specifications together.

One principle should be made clear from the start:

> **As a rule, do not modify or break parts that are already working reliably. Keep changes limited to what is necessary, and preserve compatibility with existing features.**

A new feature is not much use if it breaks something that worked before. During specification planning, decide which areas may be changed and which must be preserved.

## Step 4: Divide the Work into Development Phases and Share the Plan with AI

Once the specifications are settled, ask AI to break the implementation into several development phases.

For example, phases might cover internal logic, connection handling, UI changes, and feature-specific testing. For each phase, agree on **what needs to be done and what must be verified before it can be considered complete**. This makes it easier to track progress.

You do not have to accept AI's proposed plan as-is. Review the order and scope, revise anything you are not comfortable with, and start coding only when the plan makes sense to you.

## Step 5: Start Coding

Now ask AI to create or modify the code. At TeamGadget, development often followed this repeated cycle:

1. Ask AI to create or modify the files needed for the current phase.
2. Download the generated files.
3. **Always back up the original files.**
4. Replace the relevant files.
5. Test the changes in the actual application.
6. Report the results to AI, and make further changes only when necessary.

If your environment allows direct file editing, feel free to use an editor. What matters is **understanding what has changed and being able to restore the previous working state if something goes wrong**.

### Important: Share as Much Useful Information with AI as Possible

In vibe coding, **sharing information really is essential**.

AI cannot automatically know what is happening on your PC screen or what happened when you operated the application unless you tell it. When something goes wrong, do not stop at “It doesn't work.” Explain **what you did, what actually happened, and what you expected to happen**.

- Share error messages and logs as completely as possible.
- Describe the steps leading up to the problem, when it happened, and how to reproduce it.
- **Include screenshots** of relevant windows, settings, and the state before or after an operation.
- Report noticeable differences even if there is no error message, such as “The response feels slower than before” or “This control behaves differently.”
- **Separate confirmed facts from your own guesses.** You do not need to diagnose the cause yourself.

Screenshots are especially useful. They can communicate button states, layouts, and error locations that are difficult to describe in words alone.

**How to paste a screenshot on Windows**

1. Press `Windows + Shift + S`.
2. Select the part of the screen you want to share.
3. Press `Ctrl + V` in the chat input field to paste it.
4. Add a written explanation and send it.

For example, a report like this gives AI much more to work with:

> When I press the Connect button, the display stays at “WAIT.” G-HUB shows a connection log, but the character does not move. I've attached screenshots of the screen and log immediately after the operation. The expected behavior is for the character's pose to synchronize after connecting.

**Do not make AI guess that something is wrong in the first place.** Give it as much concrete information as possible so it can help investigate the cause.

**Note:** Before sharing screenshots or logs, check that they do not contain passwords, tokens, or personal information.

## Step 6: Pause Coding When New Problems or Ideas Come Up

**This is another very important step.**

During development, unexpected problems and new ideas are inevitable. If you keep adding changes on the fly, it becomes difficult to understand why each change was made or what it might affect.

When that happens, **stop coding for the moment**.

Discuss the situation with AI and decide whether to revise the existing specifications, choose a different approach, or defer the idea. If the specifications change, update the development phases and make sure the new plan is shared before resuming work.

> **Ideas in parallel. Development in sequence.**

There is no need to hold back ideas. Just organize the specifications first, then implement them in a deliberate order.

## Step 7: Test and Debug the Implementation

Once the main implementation is complete, move on to feature-by-feature testing.

Verify not only the new features, but also **that existing features still work**. Depending on the feature, test realistic conditions such as connecting and disconnecting, restarting the application, saving and restoring settings, and working with multiple characters.

If you find a problem, share the steps, logs, screenshots, expected behavior, and actual results, just as in Step 5. After fixing it, confirm both that the original problem is resolved and that the change has not caused problems elsewhere.

**Finishing the code and verifying that it works are two different things.**

## Step 8: Dogfooding (Extended Real-World Use)

After basic testing, use the software in your normal production workflow. This is called dogfooding.

**From this point on, you—the user—take the lead.**

The goal is not simply to see whether the features work once. Check whether the software remains stable over time, feels comfortable to use, and stays out of the way of your creative work.

During this period, I recommend **recording issues first rather than immediately changing the code**, as a general rule. Collect small bugs, usability concerns, and improvement ideas, then review them together and revisit the specifications at a suitable stopping point.

Keeping evaluation and fixes separate lets you test the same software state consistently, without constantly changing what you are evaluating.

## Step 9: Complete the Development and Decide How to Share It

Once testing and dogfooding are complete and no significant problems remain, development is finished.

You can **keep the completed Endpoint for your own use or share it with the community**.

If you decide to share it, one option is to fork the existing Endpoint repository on GitHub and publish your own extended version. Document the changes, supported versions, installation steps, and known limitations in the README so other users can make informed decisions.

Before publishing, check the licenses and redistribution conditions for the source code and everything included in the package, especially any non-public components. **Being allowed to modify something does not necessarily mean you are allowed to redistribute everything.**

---

## A Real Example: How Far Did TeamGadget Get Through Human–AI Collaboration?

To close this guide, here is the development experience behind URSS.

This is not a promise that anyone using AI can build a system of the same scale. It is **one real example of how far someone with very little formal programming knowledge was able to go by working with AI**.

### Development Scale and Timeline

| Item | TeamGadget's Experience |
| --- | --- |
| Development approach | Conversational vibe coding with ChatGPT |
| AI environment | ChatGPT Plus / GPT-5.6 Sol / highest available reasoning setting |
| URSS development period | Approximately 2.5 months |
| Total period including its predecessor, GEC | Approximately 6 months |
| Source code size | **Approximately 46,000 lines** (estimate across the development project) |
| Components developed | G-HUB, GHEC, GHEU, GHEB, GHEG, ShapeMixer Entangle |

**Note:** The line count is an approximate measure intended to convey the project's scale. Lines of code alone are not a measure of software quality or a developer's ability.

### What We Built and Verified

By combining the components developed for URSS, we implemented and tested workflows such as:

- Real-time Body synchronization between Cascadeur and Unity, Blender, and Godot
- Facial / Shape Key synchronization with ShapeMixer Entangle
- A shared timeline managed by G-HUB, with bidirectional timeline synchronization
- Offline animation baking and transfer into supported production applications
- Synchronization and testing with up to five characters
- A foundation that allows developers to extend existing Endpoints and work on new ones

This went beyond an experiment in generating code. We repeatedly tested the system in real applications and brought it to the point where it could be released as usable software.

### Where the Responsibilities Were Divided Between Human and AI

**TeamGadget (human) mainly handled:**

- Coming up with the features and workflows to build
- Making final decisions on specifications, priorities, and design choices
- Defining constraints to protect existing, stable functionality
- Installing files and operating and testing the actual applications
- Providing detailed reports with error logs, screenshots, and observations about usability
- Dogfooding and judging quality
- Making final decisions on releases and what to publish

**The AI agent mainly handled:**

- Exploring and proposing technical approaches and designs
- Creating and modifying code
- Analyzing logs and behavior reports to suggest causes and fixes
- Organizing development phases and work procedures
- Helping write technical documentation, README files, and other materials

This division of responsibilities is not a fixed rule for everyone. It describes how TeamGadget actually worked, discussing options and making decisions together throughout development.

The important point is that **code written by AI did not automatically become finished software**. We still needed to revisit specifications, deal with unsuccessful implementations, debug repeatedly, and verify the results through real use.

AI cannot know what is happening on your screen unless that information is shared. The human observes what actually happened and communicates it accurately; AI uses that information to work out possible technical solutions. This collaboration was an important part of making progress.

### What We Hope You Take Away from This Example

Even without much programming experience, **the ability to decide what you want to build, observe the results, communicate information, and make the final judgment** can make a major contribution to development.

You do not need to start by building a large Endpoint. Adding one feature you wish an existing Endpoint had is a perfectly good place to begin.

**Define the specifications. Implement in small steps. Report accurately. Test it in real use.**

Repeating that process can help you build a production environment of your own.

URSS is not intended to impose a finished workflow on creators. **It is a platform that gives creators the freedom to build their own.**

**Built with AI. Grown by Creators.**

TeamGadget
