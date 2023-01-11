# Bulk update Security Attributes for Users

### Configuration
##### Azure
Configure your azure application to have the necessary permissions
- CustomSecAttributeAssignment.ReadWrite.All
- User.ReadWrite.All
`Make sure to grant admin consent`
##### Script
Add your application ID/Client Secret/Tenant ID to the script
Add all your users to the users.txt file, they must be either UPN or Object ID

### Usage
```powershell
.\secattup.ps1 -File ./users.txt -attributeSet "" -attributeName "" -attributeValue ""
```

If you're missing a parameter the script will fail.

You include all the users with their UPN or Object ID in the `./users.txt` file and run the script to add all those users A security attribute.

Ensure you've created a security attributeset, attributename, and are using a valid value.