### Plan:

### First Sprint :

Create an architecture.drawio file and put the architecture following the hub-spoke topology: https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke 
- One Resource Group with Vnet1 contain all networking resources .
- Second Resource Group with a Vnet2 contain the other application resources.
- Create all needed subnets , network security groups .
- Keep in mind that we can use an existing resources like the app Gateway , DNS zone and others ...
- Create resources with option to support Vnet integration( resource by default public but if vnetIntegration enable the resource should be in a subnet)
