del .\compiled\FlylinkDC_x64.exe
del .\compiled\FlylinkDC_x64.pdb
rem call UpdateRevision.bat %1 %2 %3 %4
if errorlevel 1 goto :error

call tools\ExtractVersion.bat %1 %2 %3 %4
if errorlevel 1 goto :error

call "%VS140COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
"%VS140COMNTOOLS%..\ide\devenv" FlylinkDC_2015.sln /Rebuild "Release|x64"

if not exist .\compiled\FlylinkDC_x64.exe goto :builderror

"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\signtool.exe" sign /a /d "FlylinkDC++ r5xx" /du "http://flylinkdc.blogspot.com" /t http://timestamp.verisign.com/scripts/timstamp.dll ".\compiled\FlylinkDC_x64.exe"

call Tools\MakePortalBrowserFileList.bat x64
call src_gen_filename.bat -x64
7z.exe a -r -t7z -m0=lzma -mx=9 -mfb=512 -md=1024m -ms=on -x@src_exclude_hard.txt -i@PortalBrowserFileList.txt -ir@src_include_bin_x64.txt %FILE_NAME%.7z compiled/FlylinkDC_x64.exe 

call src_gen_filename.bat -debug-info
7z.exe a -r -t7z -m0=lzma -mx=9 -mfb=512 -md=1024m -ms=on -x@src_exclude_hard.txt %FILE_NAME%.7z *.pdb

goto :end

:error
echo Can't update/extract version/revision
pause
goto :end

:builderror
echo Compilation error. Building terminated.
pause

:end