class StatusPage extends React.Component {
  constructor(props) {
    super();

    this.resetIntegerField = React.createRef();

    this.onSwitchView = props.onSwitchView;
    this.onUpdateUser = props.onUpdateUser;

    this.state = {
      error: null,
      busy: false
    };
  }

  /*  fires when the next button is clicked; increments the user's integer value by one and updates
      the status page with the new value.
  */ 
  onNextButtonClick = async () => {
    this.setState({"busy": true});
    
    try {
      const userId = localStorage.getItem("userId");
      const accessToken = localStorage.getItem("accessToken");

      const response = await fetch(`${Config.API_HOST}/next/${userId}`, {
        method: "POST",
        cache: "no-cache",
        credentials: "same-origin",
        headers: {
          "Authorization": `Bearer: ${accessToken}`,
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        },
      });

      const body = await response.json();

      if (response.ok) {
        this.setState({
          "busy": false,
          "error": null
        });

        const data = body.data;

        this.onUpdateUser(data.attributes.username, data.attributes.name, data.attributes.integer_value);
      } else {
        
        this.setState({
          "busy": false,
          "error": body.errors[0]
        });
      }
    } catch (err) {
      this.setState({
        "busy": false,
        "error": `A form error occurred: ${err}`
      });
    }    
  }

  /*  fires when the reset integer button is clicked; sets the user's integer to a specific value
      and refreshes the status page with the new value.
  */ 
  onResetButtonClick = async () => {
    if (!this.resetIntegerField.current.checkValidity()) {
      this.resetIntegerField.current.reportValidity();
      return;
    }

    this.setState({"busy": true});

    try {
      const userId = localStorage.getItem("userId");
      const accessToken = localStorage.getItem("accessToken");

      const jsonData = JsonApiRequest.fromAttributesObject("users", userId, {
        integer_value: this.resetIntegerField.current.value
      });
   
      const response = await fetch(`${Config.API_HOST}/current/${userId}`, {
        method: "PUT",
        cache: "no-cache",
        credentials: "same-origin",
        headers: {
          "Authorization": `Bearer: ${accessToken}`,
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        },
        body: JSON.stringify(jsonData)
      });

      const body = await response.json();

      if (response.ok) {
        this.setState({
          "busy": false,
          "error": null
        });

        const data = body.data;

        this.onUpdateUser(data.attributes.username, data.attributes.name, data.attributes.integer_value);
      } else {
        
        this.setState({
          "busy": false,
          "error": body.errors[0]
        });
      }
    } catch (err) {
      this.setState({
        "busy": false,
        "error": `A form error occurred: ${err}`
      });
    }    
  }

  /*  logs a user out and returns them to the landing page. there is no server side component to
      this; it simply clears out the access token from local storage.
  */
  onLogoutButtonClick = () => {
    localStorage.removeItem("userId");
    localStorage.removeItem("accessToken");

    this.onSwitchView("landing-page");
  }

  render() {
    return (
      <div className="page-container">
        <div className="page">
          <h1>Integer Status</h1>

          <p>Hello {this.props.username},</p>
          <p>Your name is {this.props.name}.</p>
          <p>Your current integer is {this.props.integerValue}.</p>

          <div className={this.state.error ? "form-error": "hidden"}>{this.state.error}</div>

          <div className="button-bar status">
            <button disabled={this.state.busy} onClick={this.onNextButtonClick}>Next Integer</button>

            <div>
              <input ref={this.resetIntegerField} disabled={this.state.busy} className="short" type="number" min="0" max="1000000" />
              <button disabled={this.state.busy} className="action" onClick={this.onResetButtonClick}>Reset Integer</button>
            </div>
          </div>

          <div className="button-bar">
            <button disabled={this.state.busy} onClick={this.onLogoutButtonClick}>Logout</button>
          </div>
        </div>
      </div>
    )
  }
}
