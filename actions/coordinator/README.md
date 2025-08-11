# LabVIEW CI Task Coordinator Action

The **LabVIEW CI Task Coordinator** is a composite GitHub Action that routes to one of several LabVIEW Continuous Integration sub-actions based on a user-specified **`task`** input. It provides a single convenient interface to run common LabVIEW CI/CD tasks (builds, tests, analysis, etc.) without needing to call each action separately. This coordinator will validate the task name and execute the corresponding sub-action, or fail with an error if an unsupported task is requested.

## Supported Tasks

The following task names are supported by the coordinator (use these values for the **`task`** input):

- **`project-build`** – Builds a LabVIEW project using the specified LabVIEW version. This will invoke the LabVIEW CLI to compile the project (optionally targeting a specific build specification if provided). Use this to build executables, libraries, or FPGA bitfiles defined in a `.lvproj`.  
- **`missing-in-project`** – Checks a LabVIEW project for missing VIs or dependencies. This will open the given `.lvproj` and report any broken or missing file references (useful for detecting unresolved dependencies).  
- **`run-unit-tests`** – Runs automated unit tests in a LabVIEW project. This uses LabVIEW’s command-line test execution (for example, via VI Tester or similar framework) to run all tests in the project and report results.  
- **`apply-vipc`** – Applies a VI Package Configuration (VIPC) file for a given LabVIEW version and bitness. This installs all required LabVIEW packages/plugins listed in the specified `.vipc` file to ensure the environment is prepared (e.g. installing toolkit dependencies before a build or test run).

If an unknown task name is provided, the action will **fail** immediately with a clear error message. Ensure the **`task`** input exactly matches one of the above supported values.

## Inputs

Aside from **`task`**, which specifies which operation to perform, the coordinator accepts the following inputs. Depending on the chosen task, some inputs may be required or used while others are ignored:

- **`task`** (required): The name of the sub-task to run. Must be one of the supported task names listed above (e.g. `"project-build"`).  
- **`lv-ver`** (required): LabVIEW version year to use (for example, `"2023"`). This selects the LabVIEW installation/version under which the task will run.  
- **`arch`** (optional): LabVIEW bitness/architecture, either `32` or `64`. Default is **`64`**, which will use 64-bit LabVIEW unless specified otherwise.  
- **`project-file`** (optional): Path to the LabVIEW project file (`.lvproj`) to operate on. Default is **`main.lvproj`** in the working directory. This is used by tasks that need a project context (such as **`project-build`**, **`missing-in-project`**, and **`run-unit-tests`**).  
- **`vipc-file`** (optional): Path to a VI Package Configuration file (`.vipc`) to apply. Required when using **`apply-vipc`** (that task will install packages listed in the given VIPC file for the specified LabVIEW version). If not provided for an **`apply-vipc`** task, the action will not know which file to apply, and the step will fail.  
- **`build-spec`** (optional): Name of a specific build specification (as defined in the LabVIEW project) to build when using **`project-build`**. If provided, the action will build only that build spec. If omitted, the action will attempt to build all available build specifications in the project by default.

**Note:** Optional inputs do not have default values unless noted above. You must explicitly provide them when needed (for example, **`vipc-file`** when using **`apply-vipc`**, or **`build-spec`** if you want to target a specific build in **`project-build`**). The **`arch`** and **`project-file`** inputs have defaults as listed, and **`lv-ver`** is always required.

## Usage Example

Below is an example of a GitHub Actions workflow job that uses the coordinator to run several LabVIEW CI tasks in sequence. In this example, we apply a VIPC to install dependencies, then build the project, run its unit tests, and finally check for missing items in the project:

```yaml
jobs:
  labview-ci:
    runs-on: windows-latest  # LabVIEW CI tasks must run on a Windows runner
    steps:
      - uses: actions/checkout@v3

      - name: Install LabVIEW Dependencies
        uses: LabVIEW-Community-CI-CD/open-source-actions/coordinator@v1
        with:
          task: apply-vipc
          lv-ver: '2023'
          arch: '64'
          vipc-file: 'path/to/Dependencies.vipc'

      - name: Build LabVIEW Project
        uses: LabVIEW-Community-CI-CD/open-source-actions/coordinator@v1
        with:
          task: project-build
          lv-ver: '2023'
          arch: '64'
          project-file: 'MyProject.lvproj'
          build-spec: 'My Application Build'

      - name: Run Unit Tests
        uses: LabVIEW-Community-CI-CD/open-source-actions/coordinator@v1
        with:
          task: run-unit-tests
          lv-ver: '2023'
          arch: '64'
          project-file: 'MyProject.lvproj'

      - name: Check for Missing Files in Project
        uses: LabVIEW-Community-CI-CD/open-source-actions/coordinator@v1
        with:
          task: missing-in-project
          lv-ver: '2023'
          arch: '64'
          project-file: 'MyProject.lvproj'
