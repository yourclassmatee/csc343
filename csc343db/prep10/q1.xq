<DEALS>
{
	for $RENT_AMOUNT in fn:doc("property.xml")//PROPERTY//INFO//RENT_AMOUNT
	where data($RENT_AMOUNT) <= 800
	return 
	<DEAL> 
	{data($RENT_AMOUNT)} 
	</DEAL>
}
</DEALS>
