<#
    .SYNOPSIS
    This cmdlet is a thin wrapper for jekyll serve for testing locally.

    .DESCRIPTION
    This cmdlet runs 'bundle exec jekyll serve' with a few static default
    parameters and a few configurable parameters.

    .NOTES
    Troy Lindsay
    Twitter: @troylindsay42
    GitHub: tlindsay42

    .EXAMPLE
    .\Start-Jekyll.ps1

    Configuration file: _config.yml
    Configuration file: _config.dev.yml
         Build Warning: Skipping the initial build. This may result in an out-of-date site.
    Auto-regeneration: enabled for 'C:/Users/tlind/IDrive-Sync/git/troylindsay.github.io'
        Server address: http://127.0.0.1:4000/
    Server running... press ctrl-c to stop.
#>
[CmdletBinding()]
param (
    # Skips the initial site build which occurs before the server is started
    [Parameter( Position = 0 )]
    [Boolean] $SkipInitialBuild = $true,

    # Enable incremental rebuild
    [Parameter( Position = 1 )]
    [Boolean] $Incremental = $true,

    # Render posts that were marked as unpublished
    [Parameter( Position = 2 )]
    [Boolean] $Unpublished = $true,

    # Render posts in the _drafts folder
    [Parameter( Position = 3 )]
    [Boolean] $Drafts = $true,

    # Publishes posts with a future date
    [Parameter( Position = 4 )]
    [Boolean] $Future = $true,

    # Show the full backtrace when an error occurs
    [Parameter( Position = 5 )]
    [Boolean] $Trace = $true
)

begin {
    $function = $MyInvocation.MyCommand.Name

    Write-Verbose -Message "Beginning: '${function}'."
}

process {
    [String] $env:JEKYLL_ENV = 'development'
    [String[]] $parameters = @(
        # Custom configuration files
        '--config', '_config.yml,_config.dev.yml',
        # Safe mode
        '--safe',
        # Fail if errors are present in front matter
        '--strict_front_matter'
    )

    if ( $SkipInitialBuild -eq $true ) {
        $parameters += '--skip-initial-build'
    }

    if ( $Incremental -eq $true ) {
        $parameters += '--incremental'
    }

    if ( $Unpublished -eq $true ) {
        $parameters += '--unpublished'
    }

    if ( $Drafts -eq $true ) {
        $parameters += '--drafts'
    }

    if ( $Future -eq $true ) {
        $parameters += '--future'
    }

    if ( $Trace -eq $true ) {
        $parameters += '--trace'
    }

    if ( $VerbosePreference -eq $true ) {
        $parameters += '--verbose'
    }

    Write-Verbose -Message "bundle exec jekyll serve $parameters"
    bundle exec jekyll serve $parameters
}

end {
    Write-Verbose -Message "Ending: '${function}'."
}
