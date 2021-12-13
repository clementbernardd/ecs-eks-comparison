# Class to output the difference of cost
import fire

import plotly.express as px
import pandas as pd

class Cost(object) :
    def __init__(self):
        self.df = pd.DataFrame(
            {
                'Name': ['EKS', 'EKS', 'ECS', 'ECS'],
                'Service': ['Ec2 instance', 'EKS cluster', 'Ec2 instance','ECS cluster'],
                'Price (USD/year)': [774.48, 876, 774.48, 3.6]
            }
        )

    def plot_cost(self):
        fig = px.bar(self.df, x="Name", y="Price (USD/year)", color="Service", title="ECS vs EKS prices")
        fig.show()



if __name__ == '__main__' :
    fire.Fire(Cost)


