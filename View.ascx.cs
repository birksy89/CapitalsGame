/*
' Copyright (c) 2014  Christoc.com
'  All rights reserved.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
' TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
' THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
' CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
' DEALINGS IN THE SOFTWARE.
' 
*/

using System;
using System.Web.UI.WebControls;
using Christoc.Modules.CapitalsGame.Components;
using DotNetNuke.Security;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.UI.Utilities;

//Extra Imports
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using System.Collections.Generic;

namespace Christoc.Modules.CapitalsGame
{
    /// -----------------------------------------------------------------------------
    /// <summary>
    /// The View class displays the content
    /// 
    /// Typically your view control would be used to display content or functionality in your module.
    /// 
    /// View may be the only control you have in your project depending on the complexity of your module
    /// 
    /// Because the control inherits from CapitalsGameModuleBase you have access to any custom properties
    /// defined there, as well as properties from DNN such as PortalId, ModuleId, TabId, UserId and many more.
    /// 
    /// </summary>
    /// -----------------------------------------------------------------------------
    public partial class View : CapitalsGameModuleBase
    {

        //Create a list to store the 4 'Answers' - 1 Correct / 3 Wrong
        List<string> answers = new List<string>();

        int userLives;
        int userScore;

        protected void Page_Load(object sender, EventArgs e)
        {

            //Load Session Values from previous round - If possible
            if (Session["currentScore"] != null)
            {
                userScore = Convert.ToInt32(Session["currentScore"]);
            }
            else
            {
                userScore = 0;
            }

            //Do same for Lives
            if (Session["currentLives"] != null)
            {
                userLives = Convert.ToInt32(Session["currentLives"]);

                if (userLives < 1) // Checks to see if user has run out of lives
                {
                    Output.Attributes.Add("class", "alert alert-warning text-center");
                    Output.InnerHtml = "<p><b>You have run out of Lives! Would you like to play again?</b></p>";

                    btnSubmit.Enabled = false;
                }

            }
            else
            {
                userLives = 3;
            }

            //Display the values on the page
            txtCurrentScore.InnerText = userScore.ToString();
            txtCurrentLives.InnerText = userLives.ToString();


            //If the page isn't being posted back to check the answer...
            if (!Page.IsPostBack)
            {

                LoadSQLData();

                //Suffle Answers
                AndrewsStaticHelpers.Shuffle(answers);

                //Start building the UI - Adding Answers to Selectable Element
                rblAnswers.Items.Add(answers[0]);
                rblAnswers.Items.Add(answers[1]);
                rblAnswers.Items.Add(answers[2]);
                rblAnswers.Items.Add(answers[3]);
            }
            else
            {
                btnSubmit.Enabled = false;
            }



        }

        public void LoadSQLData()
        {
            //Load the connection from the webconfig file
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SiteSqlServer"].ToString());

            //Start using the connection (automatically closes when done "using")
            using (conn)
            {
                //Opens the connection
                conn.Open();

                //Defines a command that is to be 'used'
                using (SqlCommand command = new SqlCommand(
                    @"SELECT TOP 1 country.Name AS 'CountryName', city.Name AS 'CityName' FROM country
                        INNER JOIN city ON country.Capital = city.ID
                        ORDER BY newid()", conn))
                {
                    //Use a "Reader" to execute said command  
                    SqlDataReader reader = command.ExecuteReader();

                    //while there is stuff to be read...
                    while (reader.Read())
                    {
                        txtCountry.InnerText = reader["CountryName"].ToString().TrimEnd();
                        txtCapital.Value = reader["CityName"].ToString().TrimEnd() + ", " + reader["CountryName"].ToString().TrimEnd();

                        //Add the correct answer to the list
                        answers.Add(reader["CityName"].ToString());

                        //Add the correct answer to viewstate variable to check against later
                        ViewState["correctAnswer"] = reader["CityName"].ToString();
                    }

                    reader.Close();
                }



                //Now lets load the 'Wrong Answers'

                using (SqlCommand command = new SqlCommand(
                    @"SELECT TOP 3 Name from city ORDER BY newid()", conn))
                {
                    //Use a "Reader" to execute said command  
                    SqlDataReader reader = command.ExecuteReader();

                    //while there is stuff to be read...
                    while (reader.Read())
                    {
                        //add the wrong 'Answers' to the list
                        answers.Add(reader["Name"].ToString());

                    }
                }
            }
        }


        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            String userSelected = rblAnswers.SelectedValue;
            String correctAnswer = Convert.ToString(ViewState["correctAnswer"]);

            if (userSelected == correctAnswer)
            {
                Output.Attributes.Add("class", "alert alert-success text-center");
                Output.InnerHtml = "<p><b>Correct!</b> The capital of " + txtCountry.InnerText.TrimEnd() + " is <b>" + correctAnswer + "</b></p>";

                //Give Points
                userScore += 100;
            }
            else
            {
                Output.Attributes.Add("class", "alert alert-danger text-center");
                Output.InnerHtml = "<p>Sorry, that's wrong...The capital of " + txtCountry.InnerText.TrimEnd() + " is <b>" + correctAnswer + "</b></p>";

                //Take Points away
                userScore -= 100;

                //Take Lives away
                userLives -= 1;

            }

            //Save Score to Session
            Session["currentScore"] = userScore;
            //Output Score
            txtCurrentScore.InnerText = userScore.ToString();

            //Save lives to Session
            Session["currentLives"] = userLives;
            //Output Lives
            txtCurrentLives.InnerText = userLives.ToString();


        }

        protected void btnNext_Click(object sender, EventArgs e)
        {

            //Gets the value from the HTML field and stores in
            double distanceScore = Convert.ToDouble(txtDistanceScore.Value);

            //if (Session["distanceScore"] != null)
            //{
            //    Session["distanceScore"] = distanceScore;
            //}



            userScore = userScore + Convert.ToInt32(distanceScore);

            if (Session["currentScore"] != null)
            {
                Session["currentScore"] = userScore;
            }


            Page.Response.Redirect(Page.Request.Url.ToString(), true);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            Session.Remove("currentLives");
            Session.Remove("currentScore");

            //Session.Remove("distanceScore");

            Page.Response.Redirect(Page.Request.Url.ToString(), true);
        }



    }

    static class AndrewsStaticHelpers
    {
        // This static class was created to fix an error:
        //http://stackoverflow.com/questions/10412233/extension-method-must-be-defined-in-non-generic-static-class

        public static void Shuffle<T>(this IList<T> list)
        {
            Random rng = new Random();
            int n = list.Count;
            while (n > 1)
            {
                n--;
                int k = rng.Next(n + 1);
                T value = list[k];
                list[k] = list[n];
                list[n] = value;
            }
        }
    }



}


