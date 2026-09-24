/*
	解决【打开链接】卡顿

*/

// string GetTitle() 									-> get title for UI
// string GetVersion									-> get version for manage
// string GetDesc()										-> get detail information
// string GetLoginTitle()								-> get title for login dialog
// string GetLoginDesc()								-> get desc for login dialog
// string GetUserText()									-> get user text for login dialog
// string GetPasswordText()								-> get password text for login dialog
// string ServerCheck(string User, string Pass) 		-> server check
// string ServerLogin(string User, string Pass) 		-> login
// void ServerLogout() 									-> logout
// array<dictionary> GetCategorys()						-> get category list
// string GetSorts(string Category, string Extra, string PathToken, string Query)									-> get sort option
// array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)	-> get url list for Category

string GetTitle()
{
return "{$CP0=解决【打开链接】卡顿$}";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "";
}

array<dictionary> GetCategorys()
{
	array<dictionary> ret;
	
	dictionary item1;
	item1["title"] = "{$CP0=(推荐)$}";
	item1["Category"] = "most";
	item1["type"] = "search";
	item1["Genres"] = "";
	ret.insertLast(item1);

	return ret;
}

string GetStringValue(string param, string key)
{
	return "";
}

string GetSorts(string Category, string Extra, string PathToken, string Query)
{
	string sorts;
	return sorts;
}

bool AssignMetaData(dictionary &item, JsonValue &in snippet)
{
	bool IsDel = false;
	
	return true;
}

array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)
{
	array<dictionary> ret;

	return ret;
}
