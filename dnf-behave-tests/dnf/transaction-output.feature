Feature: Test transasction output


@dnf5
@bz1794856
Scenario: Check whitespace between columns with long values in transaction table
Given I use repository "dnf-ci-thirdparty"
 When I execute dnf with args "clean all"
 # Piping to grep is forcing DNF to print into non standard terminal which is by default limited to 80 columns.
  And I execute "eval dnf -y --releasever={context.dnf.releasever} --installroot={context.dnf.installroot} --setopt=module_platform_id={context.dnf.module_platform_id} --disableplugin='*' install forTestingPurposesWeEvenHaveReallyLongVersions | grep -v xxxxxx" in "{context.dnf.installroot}"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                                                                    |
      | install       | forTestingPurposesWeEvenHaveReallyLongVersions-0:1435347658326856238756823658aaaa-1.x86_64 |
  And stdout contains "forTestingPurposesWeEvenHaveReallyLongVersions\s+x86_64\s+1435347658326856238756823658aaaa-1\s+dnf-ci-thirdparty\s+.*"


# @dnf5
# TODO(nsella) different stdout
@bz1773436
Scenario: Packages in transaction are sorted by NEVRA
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-thirdparty"
   When I execute dnf with args "install wget glibc flac SuperRipper"
   Then the exit code is 0
    And stdout matches line by line
      """
      <REPOSYNC>
      Dependencies resolved.
      ================================================================================
       Package                Arch      Version            Repository            Size
      ================================================================================
      Installing:
       SuperRipper            x86_64    1.0-1              dnf-ci-thirdparty    *
       flac                   x86_64    1.3.2-8.fc29       dnf-ci-fedora        *
       glibc                  x86_64    2.28-9.fc29        dnf-ci-fedora        *
       wget                   x86_64    1.19.5-5.fc29      dnf-ci-fedora        *
      Installing dependencies:
       abcde                  noarch    2.9.2-1.fc29       dnf-ci-fedora        *
       basesystem             noarch    11-6.fc29          dnf-ci-fedora        *
       filesystem             x86_64    3.9-2.fc29         dnf-ci-fedora        *
       glibc-all-langpacks    x86_64    2.28-9.fc29        dnf-ci-fedora        *
       glibc-common           x86_64    2.28-9.fc29        dnf-ci-fedora        *
       setup                  noarch    2.12.1-1.fc29      dnf-ci-fedora        *
      Installing weak dependencies:
       FlacBetterEncoder      x86_64    1.0-1              dnf-ci-thirdparty    *

      Transaction Summary
      ================================================================================
      Install  11 Packages

      Total size: *
      Installed size: 0
      Downloading Packages:
      Running transaction check
      Transaction check succeeded.
      Running transaction test
      Transaction test succeeded.
      Running transaction
        Preparing        :                                                        1/1
        Installing       : setup-2.12.1-1.fc29.noarch                            1/11
        Installing       : filesystem-3.9-2.fc29.x86_64                          2/11
        Installing       : basesystem-11-6.fc29.noarch                           3/11
        Installing       : glibc-all-langpacks-2.28-9.fc29.x86_64                4/11
        Installing       : glibc-common-2.28-9.fc29.x86_64                       5/11
        Installing       : glibc-2.28-9.fc29.x86_64                              6/11
        Installing       : FlacBetterEncoder-1.0-1.x86_64                        7/11
        Installing       : flac-1.3.2-8.fc29.x86_64                              8/11
        Installing       : wget-1.19.5-5.fc29.x86_64                             9/11
        Installing       : abcde-2.9.2-1.fc29.noarch                            10/11
        Installing       : SuperRipper-1.0-1.x86_64                             11/11
        Verifying        : abcde-2.9.2-1.fc29.noarch                             1/11
        Verifying        : basesystem-11-6.fc29.noarch                           2/11
        Verifying        : filesystem-3.9-2.fc29.x86_64                          3/11
        Verifying        : flac-1.3.2-8.fc29.x86_64                              4/11
        Verifying        : glibc-2.28-9.fc29.x86_64                              5/11
        Verifying        : glibc-all-langpacks-2.28-9.fc29.x86_64                6/11
        Verifying        : glibc-common-2.28-9.fc29.x86_64                       7/11
        Verifying        : setup-2.12.1-1.fc29.noarch                            8/11
        Verifying        : wget-1.19.5-5.fc29.x86_64                             9/11
        Verifying        : FlacBetterEncoder-1.0-1.x86_64                       10/11
        Verifying        : SuperRipper-1.0-1.x86_64                             11/11

      Installed:
        FlacBetterEncoder-1.0-1.x86_64      SuperRipper-1.0-1.x86_64
        abcde-2.9.2-1.fc29.noarch           basesystem-11-6.fc29.noarch
        filesystem-3.9-2.fc29.x86_64        flac-1.3.2-8.fc29.x86_64
        glibc-2.28-9.fc29.x86_64            glibc-all-langpacks-2.28-9.fc29.x86_64
        glibc-common-2.28-9.fc29.x86_64     setup-2.12.1-1.fc29.noarch
        wget-1.19.5-5.fc29.x86_64

      Complete!
      """
