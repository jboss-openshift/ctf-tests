@openshift
Feature: Openshift JDG jgroups secure

  @datagrid_6_5
  Scenario: jgroups-encrypt
    Given XML namespaces
     | prefix | url                            |
     | ns     | urn:infinispan:server:jgroups:6.1 |
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //ns:protocol[@type='ENCRYPT']
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value /etc/jgroups-encrypt-secret-volume/keystore.jks on XPath //ns:protocol[@type='ENCRYPT']/ns:property[@name='key_store_name']
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jboss on XPath //ns:protocol[@type='ENCRYPT']/ns:property[@name='alias']
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeystorepass on XPath //ns:protocol[@type='ENCRYPT']/ns:property[@name='store_password']
     # https://issues.jboss.org/browse/CLOUD-1199
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK2 for udp stack
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value pbcast.NAKACK2 on XPath //ns:stack[@name='udp']/ns:protocol[@type='ENCRYPT']/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK2 for tcp stack
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value pbcast.NAKACK2 on XPath //ns:stack[@name='tcp']/ns:protocol[@type='ENCRYPT']/following-sibling::*[1]/@type

  @datagrid_7_1
  Scenario: jgroups-encrypt
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='SYM_ENCRYPT']
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value /etc/jgroups-encrypt-secret-volume/keystore.jks on XPath //*[local-name()='protocol'][@type='SYM_ENCRYPT']/*[local-name()='property'][@name='keystore_name']
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jboss on XPath //*[local-name()='protocol'][@type='SYM_ENCRYPT']/*[local-name()='property'][@name='alias']
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='protocol'][@type='SYM_ENCRYPT']/*[local-name()='property'][@name='store_password']
     # https://issues.jboss.org/browse/CLOUD-1199
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK2 for udp stack
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()='stack'][@name='udp']/*[local-name()='protocol'][@type='SYM_ENCRYPT']/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK2 for tcp stack
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()='stack'][@name='tcp']/*[local-name()='protocol'][@type='SYM_ENCRYPT']/following-sibling::*[1]/@type

  @datagrid
  Scenario: CLOUD-336 Check if jgroups is secure
    When container is started with env
       | variable                 | value    |
       | JGROUPS_CLUSTER_PASSWORD | asdfasdf |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='AUTH']

  @datagrid
  Scenario: Check jgroups encryption does not create invalid configuration with missing name
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then available container log should contain WARNING! Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @datagrid
  Scenario: Check jgroups encryption does not create invalid configuration with missing password
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
    Then available container log should contain WARNING! Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.
