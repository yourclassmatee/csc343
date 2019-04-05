<COMMERCIAL_UNITS>
{
	let $pro:=doc("property.xml")
	for $INFO in $pro//PROPERTY//COMMERCIAL//INFO
	return 
	<UNIT> 
	{$INFO} 
	{$INFO/ancestor::PROPERTY//ADDRESS} 
	</UNIT>
}
</COMMERCIAL_UNITS>
