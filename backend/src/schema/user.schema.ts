import joi from "joi";

// Validate the request body of 'signup'
const signupSchema = joi.object({
    id: joi.string().required(),
    name: joi.string().required(),
    username: joi.string().required(),
    password: joi.string()
        //.regex(RegExp('(?=.*[A-Z])'))
        //.regex(RegExp('(?=.*[a-z])'))
        //.regex(RegExp('(?=.*?[0-9])'))
        //.regex(RegExp('(?=.*?[!@#\$&*~])'))
        //.regex(RegExp('.{8,}'))
        .optional(),
        
    email: joi.string().optional(),
    phone: joi.string().optional(),
    profileImage: joi.string().optional(),
    
});

// Validate the request body of 'signin
const signinSchema = joi.object({
    username: joi.string().required(),
    password: joi.string().optional()
    // email: joi.string().required(),
});

export {
    signupSchema,
    signinSchema
}
