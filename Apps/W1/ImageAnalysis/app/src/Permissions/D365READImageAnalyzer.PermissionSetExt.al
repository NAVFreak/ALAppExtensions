namespace System.Security.AccessControl;

using Microsoft.Utility.ImageAnalysis;
using System.Security.AccessControl;

permissionsetextension 6820 "D365 READImage Analyzer" extends "D365 READ"
{
    Permissions = tabledata "MS - Image Analyzer Tags" = R,
                  tabledata "MS - Img. Analyzer Blacklist" = R;
}
