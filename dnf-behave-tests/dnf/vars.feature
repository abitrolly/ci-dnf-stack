Feature: Subtitute variables


# @dnf5
# TODO(nsella) different exit code
@bz1651092
Scenario: Variables are substituted in mirrorlist URLs
  Given I use repository "dnf-ci-fedora" with configuration
      | key        | value                                               |
      | mirrorlist | {context.dnf.installroot}/temp-repos/mirrorlist.txt |
      | baseurl    |                                                     |
    And I copy directory "{context.scenario.repos_location}/dnf-ci-fedora" to "/temp-repos/base-noarch"
    And I create and substitute file "/temp-repos/mirrorlist.txt" with
      """
      file:///{context.dnf.installroot}/temp-repos/base-$basearch/
      """
   Then I set config option "basearch" to "noarch"
    And I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
      | Action        | Package                       |
      | install       | setup-0:2.12.1-1.fc29.noarch  |


# @dnf5
# TODO(nsella) different stdout
Scenario: Variables arch supports basearch `loongarch64` {}
  Given I create file "/etc/dnf/vars/distrib" with
      """
      fedora
      """
    And I create file "/etc/yum.repos.d/dnf-ci-test.repo" with
      """
      [dnf-ci-test-$arch-$basearch]
      name=dnf-ci-test-$distrib test repository
      enabled=0
      """
   Then I set config option "arch" to "loongarch64"
   When I execute dnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-test-loongarch64-loongarch64\s+dnf-ci-test-fedora test repository
      """


# @dnf5
# TODO(nsella) different stdout
@bz1748841
Scenario: Variables without {} are substituted in repo id
  Given I create file "/etc/dnf/vars/distrib" with
      """
      fedora
      """
    And I create file "/etc/yum.repos.d/dnf-ci-test.repo" with
      """
      [dnf-ci-test-$distrib]
      name=dnf-ci-test-$distrib test repository
      enabled=0
      """
   When I execute dnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-test-fedora\s+dnf-ci-test-fedora test repository
      """

# @dnf5
# TODO(nsella) different stdout
Scenario: Variables with {} are substituted in repo id
  Given I create file "/etc/dnf/vars/distrib" with
      """
      fedora
      """
    And I create file "/etc/yum.repos.d/dnf-ci-test.repo" with
      """
      [dnf-ci-test-${distrib}]
      name=dnf-ci-test-${distrib} test repository
      enabled=0
      """
   When I execute dnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-test-fedora\s+dnf-ci-test-fedora test repository
      """

@bz2091636
Scenario: Using dnf with non-files in /etc/dnf/vars
  Given I create directory "/{context.dnf.installroot}/etc/dnf/vars/troublemaker"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-fedora\s+dnf-ci-fedora test repository
      """

