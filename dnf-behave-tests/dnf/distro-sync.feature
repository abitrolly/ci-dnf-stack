Feature: distro-sync


@dnf5
Scenario: when there is noting to do
Given I use repository "simple-base"
 When I execute dnf with args "distro-sync"
 Then the exit code is 0
  And Transaction is empty


@dnf5
Scenario: updating a pkg
Given I use repository "simple-base"
  And I execute dnf with args "install labirinto"
  And I use repository "simple-updates"
 When I execute dnf with args "distro-sync"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                               |
      | upgrade       | labirinto-2.0-1.fc29.x86_64           |


@dnf5
Scenario: updating a signed pkg
Given I use repository "simple-base"
  And I execute dnf with args "install dedalo-signed"
  And I use repository "simple-updates" with configuration
      | key      | value      |
      | gpgcheck | 1          |
      | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public |
 When I execute dnf with args "distro-sync"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                               |
      | upgrade       | dedalo-signed-2.0-1.fc29.x86_64       |


@dnf5
Scenario: updating a signed pkg without key specified
Given I use repository "simple-base"
  And I execute dnf with args "install dedalo-signed"
  And I use repository "simple-updates" with configuration
      | key      | value      |
      | gpgcheck | 1          |
 When I execute dnf with args "distro-sync"
 Then the exit code is 1


@dnf5
Scenario: updating a broken signed pkg whose key is not imported
Given I use repository "dnf-ci-gpg"
  And I execute dnf with args "install wget"
  And I use repository "dnf-ci-gpg-updates" with configuration
      | key      | value      |
      | gpgcheck | 1          |
      | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-updates/dnf-ci-gpg-updates-public |
 When I execute dnf with args "distro-sync wget"
 Then the exit code is 1
  And dnf4 stderr contains "Error: GPG check FAILED"
  And dnf5 stderr matches line by line
    """
    GPG check for package "wget-2\.0\.0-1\.fc29\.x86_64" \(.*/wget-2.0.0-1.fc29.x86_64.rpm\) from repo "dnf-ci-gpg-updates" has failed: problem opening package.
    Signature verification failed
    """


@dnf5
@bz1963732
@not.with_os=rhel__ge__8
Scenario: updating a broken signed pkg whose key is imported
Given I use repository "dnf-ci-gpg"
  And I execute dnf with args "install wget"
  And I use repository "dnf-ci-gpg-updates" with configuration
      | key      | value      |
      | gpgcheck | 1          |
      | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-updates/dnf-ci-gpg-updates-public |
  And I execute rpm with args "--import {context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-updates/dnf-ci-gpg-updates-public"
 When I execute dnf with args "distro-sync wget"
 Then the exit code is 1
  And dnf4 stderr contains "Error: GPG check FAILED"
  And dnf5 stderr matches line by line
    """
    GPG check for package "wget-2\.0\.0-1\.fc29\.x86_64" \(.*/wget-2.0.0-1.fc29.x86_64.rpm\) from repo "dnf-ci-gpg-updates" has failed: problem opening package.
    Signature verification failed
    """
