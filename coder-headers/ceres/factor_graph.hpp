// Copyright 2021-2022 The MathWorks, Inc.
#ifndef FACTOR_GRAPH_HPP
#define FACTOR_GRAPH_HPP

#include <vector>
#include <unordered_map>
#include <map>
#include <limits>
#include <memory>
#include <algorithm>
#include "ceres/ceres.h"

#ifdef BUILDING_LIBMWCERESCODEGEN
    #include "cerescodegen/cerescodegen_spec.hpp"
    #include "cerescodegen/factor.hpp"
#else
    /* To deal with the fact that PackNGo has no include file hierarchy during test */
    #include "cerescodegen_spec.hpp"
    #include "factor.hpp"
#endif

namespace mw_ceres {

    enum FactorTypeEnum {Two_SE2_F, Two_SE3_F, SE2_Point2_F, SE3_Point3_F, IMU_F, GPS_F, SE2_Prior_F, SE3_Prior_F, IMU_Bias_Prior_F, Vel3_Prior_F};

    /// TODO
    struct Variable {
        int Dim;
        int Type;
        std::vector<double> State;
    };

    /// Commonly used trust region solver parameters
    struct CERESCODEGEN_API CeresSolverOptions {
        
        /// Trust region algorithm specifics
        
        /// LEVENBERG_MARQUARDT or DOGLEG (default). Note this default is different from Ceres
        int TrustRegionStrategyType;
        
        /// TRADITIONAL_DOGLEG (default) or SUBSPACE_DOGLEG  
        int DoglegType;

        /// SPARSE_NORMAL_CHOLESKY (default) or DENSE_QR
        int LinearSolverType;

        /// Size of the initial trust region. (default 1e4)
        double InitialTrustRegionRadius;

        /// General
        
        /// Maximum number of iterations. (default 200)
        int MaxNumIterations;

        /// |new_cost - old_cost| < FunctionTolerance * old_cost (cost is always > 0). (default 1e-6)
        double FunctionTolerance;

        /// max_norm ( x - [x oplus -g(x)] ) <= GradientTolerance. (default 1e-10)
        double GradientTolerance;

        /// |delta_x| <= (|x| + StepTolerance) * StepTolerance (1e-8)
        double StepTolerance;

        /// 0 - no printing, 1 - only summary, 2 - per iteration + summary. (default 1)
        int VerbosityLevel;

        CeresSolverOptions() {
            TrustRegionStrategyType = ceres::DOGLEG;
            DoglegType = ceres::TRADITIONAL_DOGLEG;
            LinearSolverType = ceres::SPARSE_NORMAL_CHOLESKY;
            InitialTrustRegionRadius = 1e4;
            MaxNumIterations = 200;
            FunctionTolerance = 1e-6;
            GradientTolerance = 1e-10;
            StepTolerance = 1e-8;
            VerbosityLevel = 1;
        }
    };

    /// A (very) brief summary of the state of solver after optimization
    struct CERESCODEGEN_API CeresSolutionInfo {
        /// Cost of the objective function before the optimization
        double InitialCost;

        /// Cost of the objective function after the optimization
        double FinalCost;

        /// Number of iterations in which the step was accepted 
        int NumSuccessfulSteps;

        /// Number of iterations in which the step was rejected 
        int NumUnsuccessfulSteps;

        /// Time spent in the solver
        double TotalTime;

        /// Cause of minimizer terminating
        /// The options are CONVERGENCE, NO_CONVERGENCE, FAILURE, 
        int TerminationType;

        /// Reason why the solver terminated
        std::string Message;

        /// Whether the solution returned by optimizer is numerically sane
        /// This is the case if the TerminationType is CONVERGENCE or NO_CONVERGENCE
        bool IsSolutionUsable;
    };

    
    // NOTE Ceres problem definition only supports double as "too much pain and suffering in single precision land"

    /// <summary>
    /// A factor graph is a bipartite graph consisting of factors connected to variables.
    /// The variables represent the unknown random variables in the estimation problem,
    /// whereas the factors represent probabilistic constraints on those variables,
    /// derived from measurements or prior knowledge.
    /// </summary>
    class CERESCODEGEN_API FactorGraph {

    public:
        FactorGraph() : m_NumFactors(0), m_UniqueFactorID(0) {
            m_FactorType = { {"Two_SE2_F", FactorTypeEnum::Two_SE2_F},
                             {"Two_SE3_F", FactorTypeEnum::Two_SE3_F},
                             {"SE2_Point2_F", FactorTypeEnum::SE2_Point2_F},
                             {"SE3_Point3_F", FactorTypeEnum::SE3_Point3_F},
                             {"IMU_F", FactorTypeEnum::IMU_F},
                             {"GPS_F", FactorTypeEnum::GPS_F},
                             {"SE2_Prior_F", FactorTypeEnum::SE2_Prior_F},
                             {"SE3_Prior_F", FactorTypeEnum::SE3_Prior_F},
                             {"IMU_Bias_Prior_F", FactorTypeEnum::IMU_Bias_Prior_F},
                             {"Vel3_Prior_F", FactorTypeEnum::Vel3_Prior_F}};
        }

        ~FactorGraph() {}

        // Explicitly delete the copy constructor and copy assignment operator
        // So that DLL_EXPORT (on Windows) can work correctly
        FactorGraph(const FactorGraph &) = delete;
        FactorGraph &operator=(const FactorGraph &) = delete;

        // default in move constructor/assignment
        FactorGraph &operator=(FactorGraph &&) = default;
        FactorGraph(FactorGraph &&) = default;

        /// Whether the factor graph is connected
        bool isConnected() const;

        /// Add a factor
        int addFactor(std::unique_ptr<Factor> fctr);

        /// Add a gaussian noise model factor
        int addGaussianFactor(const char* factorType, const size_t factorTypeLen, const double* ids, const size_t numIds, const double* measurement, const double* information);

        /// Add a variable. Note this API is not required before calling addFactor.
        int addVariable(int id, std::vector<double> state, int varType);

        /// Update state in a variable
        int setVariableState(int id, const std::vector<double>& var);

        template <typename VarType>
        bool setVariableState(int id, const VarType&& var) {
            return setVariableState(id, var);
        }

        /// Retrieve state of a variable
        std::vector<double> getVariableState(int id) const {
            auto iter = m_MapOfVariables.find(id);
            if (iter == m_MapOfVariables.end())
                return std::vector<double>{std::numeric_limits<double>::quiet_NaN()};

            return iter->second;
        }

        // get variable state as an array
        void getVariableStateArray(int id, double* state, double* stateLen) const {
            std::vector<double> v = getVariableState(id);
            // fill output array
            for(size_t k=0;k<v.size();k++){
                state[k] = v[k];
            }
            stateLen[0] = (double)v.size();
        }

        // set variable state using an array input
        void setVariableStateArray(int id, double* state, size_t stateLen) {
            std::vector<double> v(state,state+stateLen);
            setVariableState(id,v);
        }

         /// Retrieve all variable IDs in the graph
        std::vector<int> getAllVariableIDs() const {
            std::vector<int> ids(m_MapOfVariables.size(), 0);
            size_t cnt = 0;
            for (auto& p : m_MapOfVariables) {
                ids[cnt++] = p.first;
            }
            std::sort(ids.begin(), ids.end());
            return ids;
        }
        
        /// Retrieve all variable IDs in the graph and fill output array
        void getAllVariableIDs(double* ids) const {
            size_t numVar = m_MapOfVariables.size();
            size_t cnt =0;
            for (auto& p : m_MapOfVariables) {
                ids[cnt++] = p.first;
            }
            std::sort(ids, ids+numVar);
        }

        /// Retrieve the type of a variable
        int getVariableType(int id) const {
            auto iter = m_MapOfVariableTypes.find(id);
            if (iter == m_MapOfVariableTypes.end())
                return -1;

            return iter->second;
        }

        /// Retrieve the user-facing variable type string
        std::string getVariableTypeString(int id) const {
            int typeId = getVariableType(id);
            if (typeId == -1) return "";
            return VariableTypeString.at(static_cast<VariableType>(typeId));
        }

        /// Retrieve the user-facing variable type as char
        void getVariableTypeChar(int id, char* type, double* typeLen) const {
            std::string t = getVariableTypeString(id);
            std::copy(t.begin(),t.end(),type);
            *typeLen = (double)t.size();
        }

        /// Retrieve the number of factors in the graph
        int getNumFactors() const {
            return m_NumFactors;
        }

        /// Retrieve the number of variables in the graph
        int getNumVariables() const {
            return static_cast<int>(m_MapOfVariables.size());
        }

        /// Whether a variable with given ID exists in the graph
        bool hasVariable(int id) const {
            return m_MapOfVariables.count(id) == 1 ? true : false;
        }

        /// Freeze/fix a variable so that its state does not change in optimization
        bool fixVariable(int id);

        /// Unfreeze/free a variable
        bool freeVariable(int id);

        // Check if a variable is frozen (fixed) or not
        int isVariableFixed(int id) const;

        /// Optimize the graph using current states in variables as initial guess.
        /// The optimized result is updated in place.
        CeresSolutionInfo optimize(const CeresSolverOptions& optStruct);
        void optimize(double* opts, double* info) ; // for codegen call

    protected:
        /// This is currently the map from variable ID to variable state
        std::unordered_map<int, std::vector<double>> m_MapOfVariables;

        /// This is currently the map from variable ID to variable state dimension
        std::unordered_map<int, int> m_MapOfVariableDims;

        /// This is currently the map from variable ID to variable (local parameterization) type
        std::unordered_map<int, int> m_MapOfVariableTypes;

        /// This is currently the map from variable ID to whether this variable is held constant during graph optimization or not
        std::unordered_map<int, bool> m_MapOfVariableIsConstant;

        /// Map from unique factor ID to the unique pointer of the factor object
        std::map<int, std::unique_ptr<Factor>> m_MapOfFactors;

        // Map of factor type string to the unique ID
        std::unordered_map<std::string, int> m_FactorType;

        /// Number of factors in the graph
        int m_NumFactors;

        /// Next factor ID
        int m_UniqueFactorID;
    };


    inline bool FactorGraph::fixVariable(int id) {
        if (m_MapOfVariables.find(id) == m_MapOfVariables.end()) {
            return false;
        }
        m_MapOfVariableIsConstant[id] = true;
        return true;
    }

    inline bool FactorGraph::freeVariable(int id) {
        if (m_MapOfVariables.find(id) == m_MapOfVariables.end()) {
            return false;
        }
        m_MapOfVariableIsConstant[id] = false;
        return true;
    }

    inline int FactorGraph::isVariableFixed(int id) const {
        auto it = m_MapOfVariables.find(id);
        if (it == m_MapOfVariables.end()) {
            return -1;
        }
        if (m_MapOfVariableIsConstant.at(id)) {
            return 1;
        } else {
            return 0;
        }
    }


}



#endif // FACTOR_GRAPH_HPP
