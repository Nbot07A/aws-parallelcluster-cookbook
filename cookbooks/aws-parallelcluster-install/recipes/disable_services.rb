# frozen_string_literal: true

#
# Cookbook:: aws-parallelcluster
# Recipe:: disable_services
#
# Copyright:: 2013-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# Disable DLAMI multi eni helper
# no only_if statement because if the service is not present the action disable does not return error
disable_service('aws-ubuntu-eni-helper', 'debian', %i(disable stop mask))

# Disable log4j-cve-2021-44228-hotpatch
# masking the service in order to prevent it from being automatically enabled
# if not installed yet
disable_service('log4j-cve-2021-44228-hotpatch', 'amazon', %i(disable stop mask))
