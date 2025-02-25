Describe "Maven" {

    $mavenToolManifest = Get-ManifestTool -Name "Maven"

    $certificateAliases = @("NFCU_Root_CA_R3", "NFCU_SSL_CA01_I2", "cloudproxy_nfcu_net")

    $certificateTestCases = [PSObject[]]::new($certificateAliases.Count * $mavenToolManifest.versions.Count)

    $versionTestCases = [string[]]::new($mavenToolManifest.versions.Count)

    $certificateIndex = 0

    $versionindex = 0

    foreach ($version in $mavenToolManifest.versions) {

        $versionTestCases[$versionindex] = @{

            MajorVersion = $version.Split('.')[0]

            Version      = $version

        }

        foreach ($certificateAlias in $certificateAliases) {

            $certificateTestCases[$certificateIndex] = @{

                CertificateAlias = $certificateAlias

                Version          = $version

            }

            $certificateIndex++

        }

        $versionindex++

    }

    $mavenToolManifest.versions | ForEach-Object { @{ Version = $_.Split('.')[0] } }

    It "Maven <DefaultMavenVersion> is default" -TestCases @(@{ DefaultMavenVersion = $mavenToolManifest.defaultVersion.Split('.')[0] }) {

        $actualMavenPath = Get-EnvironmentVariable "MAVEN_HOME"

        $expectedMavenPath = Get-EnvironmentVariable "MAVEN_HOME_${DefaultMavenVersion}_X64"

        $actualMavenPath | Should -Not -BeNullOrEmpty

        $expectedMavenPath | Should -Not -BeNullOrEmpty

        $actualMavenPath | Should -Be $expectedMavenPath

    }

    It "<MajorVersion> is installed" -TestCases $versionTestCases {

        $mavenVariableValue = Get-EnvironmentVariable "MAVEN_HOME_${MajorVersion}_X64"

        $mavenVariableValue | Should -Not -BeNullOrEmpty

        $mavenPath = Join-Path $mavenVariableValue "bin\mvn"

        $outputPattern = "Apache Maven $Version"

        $outputLines = (& $env:comspec /c "`"$mavenPath`" --version 2>&1") -as [string[]]

        $LASTEXITCODE | Should -Be 0

        $outputLines[0] | Should -Match $outputPattern

    }

    It "<Version> has the <CertificateAlias> certificate installed" -TestCases $certificateTestCases {

        $mavenBinPath = "C:\software\maven\maven-$Version\bin"

        $keytool = Join-Path $mavenBinPath "keytool"

        cmd /c "$keytool -list -cacerts -alias $CertificateAlias -storepass changeit"

        $LASTEXITCODE | Should -Be 0

    }

}
