# Production Safety

<EXTREMELY_IMPORTANT>

The rules below are MANDATORY whenever you touch AWS resources or credentials, and you MUST follow them so that production credentials are used safely:

1. **Credential Selection** - For anything that does not require write access, you SHOULD reach for ReadOnly or otherwise least-privilege credentials rather than Admin ones
2. **Production Resource Deletion** - You MUST NOT remove resources in a production environment unless the user has directed you to, as doing so risks service outages and data loss
3. **Assume Production When Uncertain** - When you cannot tell whether a resource or credential belongs to production, you MUST treat it as production and proceed with maximum caution, because an accidental production change can be severe
4. **Non-Destructive Operations** - Wherever a task allows it, you SHOULD choose read, describe, or list calls in place of modify, update, or delete ones
5. **Destructive Action Confirmation** - Before any potentially destructive action against production (delete, terminate, modify), you MUST ask the user to confirm explicitly and MUST spell out the impact, since nobody can approve a consequence they have not been told about
6. **Safety Protection Disablement** - You MUST NOT turn off safety protections in production without explicit user confirmation and a clear justification. Termination protection, deletion protection, MFA delete, versioning, backup retention policies, and comparable safeguards all count, because they are what stands between a mistake and lost data or a disrupted service

</EXTREMELY_IMPORTANT>

## Identifying Production Resources and Credentials

**Account** - In a multi-account setup this is the clearest production signal there is. Production usually gets an AWS account to itself, so establish which account you are in before you lean on resource-level hints:
- `aws sts get-caller-identity --query Account --output text` for the account ID
- `aws iam list-account-aliases --query 'AccountAliases[0]' --output text` for the account alias
- Unless the ID or alias is known to be non-production, you MUST treat the account as production. Inside a production account, a resource with no environment indicator on it IS a production resource.

**Credential types** - Identify by:
- Scanning `~/.aws/config` profile names for markers such as `ReadOnly`, `Admin`, `Prod`, `Staging`, or `Dev` (if using profiles)
- Running `aws sts get-caller-identity` and reading the role name out of the ARN (add `--profile <name>` if using profiles). What comes back is an assumed-role ARN shaped like `arn:aws:sts::<account>:assumed-role/<RoleName>/<session>`, so the role name is that middle segment rather than the full ARN. With IAM Identity Center it shows up as `AWSReservedSSO_<PermissionSet>_<suffix>`, and the permission set name is what tells you the privilege level.
- Running `aws iam list-attached-role-policies --role-name <RoleName>` for attached managed policies, plus `aws iam list-role-policies --role-name <RoleName>` for inline ones. You MUST be careful when `AdministratorAccess` or `FullAccess` shows up among them. Both commands depend on `iam:List*` permissions that a narrowly scoped role might not hold — should they fail, rely on the account and role-name signals above instead of concluding the role is low-privilege.

**Production resources** - Look for these indicators:
- A resource name or tag that contains `prod`, `production`, or `prd`
- No non-production marker present, such as `dev`, `test`, `qa`, `uat`, `staging`, `stage`, `preprod`, `nonprod`, `sandbox`, `demo`, or `local`
