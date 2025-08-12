@{
    RootModule        = 'OpenSourceActions.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '79fd6e1c-a2c9-48da-b707-daa478479505'
    Author            = 'LabVIEW Community CI/CD'
    CompanyName       = 'LabVIEW Community'
    Copyright         = '(c) 2025 LabVIEW Community'
    Description       = 'Unified dispatcher adapters for open-source-actions'
    FunctionsToExport = @(
        'InvokeApplyVIPC',
        'InvokeBuildLvlibp',
        'InvokeMissingInProject',
        'InvokeRunUnitTests',
        'Format-UnitTestReport'
    )
    PrivateData = @{
        PSData = @{
            ReleaseNotes = @(
                '1.0.0 - Initial release with unified dispatcher and adapters for ApplyVIPC, BuildLvlibp, MissingInProject, RunUnitTests; includes Format-UnitTestReport and composite action.'
            )
        }
    }
}
