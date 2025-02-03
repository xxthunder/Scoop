BeforeAll {
    . "$PSScriptRoot\Scoop-TestLib.ps1"
    . "$PSScriptRoot\..\lib\core.ps1"
    . "$PSScriptRoot\..\lib\system.ps1"
    . "$PSScriptRoot\..\lib\install.ps1"
}

Describe 'shim_timeout' -Tag 'Scoop', 'Windows' {
    BeforeAll {
        $working_dir = setup_working 'shim'
        $shimdir = shimdir
        Add-Path $shimdir
        $timeout_exe = Join-Path $PSScriptRoot ".\fixtures\shim\clickme\dist\clickme.exe"
        Mock get_shim_path { Join-Path $PSScriptRoot "..\supporting\shims\kiennq\shim.exe" }
        shim $timeout_exe $false 'clickme'
    }

    It "check if shim is created correctly" {
        $shim = Get-Command 'clickme'
        $shim | Should -Not -BeNullOrEmpty
        $shim.Name | Should -Be 'clickme.exe'
        $shim.CommandType | Should -Be 'Application'
    }

    It "should return exit code 0 when calling with no arguments" {
        { Get-Command 'clickme' -ea stop } | Should -Not -Throw
        $process = Start-Process "clickme" -PassThru -Wait
        $process.ExitCode | Should -Be 0
    }

    It "should return exit code 5 when calling it with parameter 5" {
        { Get-Command 'clickme' -ea stop } | Should -Not -Throw
        $process = Start-Process "clickme" -ArgumentList @("5") -PassThru -Wait
        $process.ExitCode | Should -Be 5
    }

    It "should return exit code -1 when terminating it" {
        { Get-Command 'clickme' -ea stop } | Should -Not -Throw
        $process = Start-Process "clickme" -ArgumentList @("2") -PassThru
        $process.HasExited | Should -Be $false
        Start-Sleep -Seconds 3
        $process.HasExited | Should -Be $false
        Stop-Process -Id $process.Id
        $process.WaitForExit()
        $process.HasExited | Should -Be $true
        $process.ExitCode | Should -Be -1

    }


    AfterEach {
        rm_shim 'shim-timeout' $shimdir
    }
}
