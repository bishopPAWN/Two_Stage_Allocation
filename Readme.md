# Readme

This project corresponds to the paper **"A Two-Stage Profit Allocation Method for Virtual Power Plants Considering Uncertainties"**, which is currently under preparation and has not yet been submitted.

This repository provides partial code and interface structures for our research project. It aims to:

- Show the core implementation structure;
- Help reviewers or interested researchers understand or partially reproduce the results;
- Serve as a basis for full open-sourcing in the future.

❗Full datasets and detailed implementation will be released after the paper is accepted.

##  Project Structure

```
├── README.md  
│   └── Project documentation.

├── Case_5_1_Energy_Market_Toy_Case/                     # Toy case for the energy market  
│   ├── Energy_Market_Case.m                             # Code for optimization and value computation  
│   └── Profit_allocation_proposed.xlsx                  # Profit allocation process of the proposed method  

├── Case_5_2_Shenzhen_Case/                              # Real-world case for the Shenzhen demand response market  
│   ├── Shenzhen_Case.m                                  # Code for profit allocation calculation  
│   └── Towngas_Case.xlsx                                # Detailed data used for the allocation process  

├── Case_5_3_Shenzhen_Future_Case/                       # Shenzhen future case (based on actual operation data)  
│   └── Allocation_Solution_Paper_Data/                  # Allocation results used in the paper  
│       ├── Without_operator/                            # Allocation matrices without considering the operator  
│       └── Consider_Operator/                           # Allocation solutions including operator participation  
│    *Note: Due to the sensitivity of real operational data, full data access is restricted. Please contact us if needed.  
│      However, the profit allocation results can still be reproduced using the provided matrices.  

├── Allocation_Functions/                                # Core functions used for profit allocation  
│   ├── compute_Least_Core.m                             # Least Core allocation implementation  
│   ├── compute_dp.m                                     # Equal DP allocation method  
│   ├── compute_shapley.m                                # Shapley value allocation  
│   ├── Operator_2.m                                     # Matrix generation with operator consideration  
│   ├── Binary_list.m                                    # Generates all member combinations  
│   ├── Consider_Operator.m                              # Allocation calculation considering the operator  
│   └── Without_Operator.m                               # Matrix generation for the "Consider_Operator" function  
```

## Project Status

This project is currently under active development.  
The associated paper is in the writing stage and has not yet been submitted for peer review.  
We plan to make the full code, data, and documentation publicly available after acceptance.

#  Notes

To protect intellectual property, certain parts of the code or data may be redacted or simplified.
 If you require further clarification, feel free to contact us via the email : wsc23@mails.tsinghua.edu.cn

##  License

This code is currently released for academic preview only and is not yet licensed for public use.  
Please do not reuse or redistribute without permission.  
Final licensing terms will be added after formal publication.